// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PrescriptionVerification {
    address[] public patients; // List of patients
    address[] public doctors; // List of doctors
    mapping (address => bool) isDoctor;
    mapping (address => uint256[]) doctorRecords; // Records of prescriptions created by each doctor
    mapping (address => uint256[]) patientRecords; // Records of prescriptions approved by each patient
    mapping (uint256 => Prescription) private medicalRecords; // All prescription records
    address owner;
    uint256 nonce = 0;

    // Events
    event PatientAdded(address patient);
    event DoctorAdded(address doctor);
    event PrescriptionAdded(uint256 nonce, address doctor, address patient);
    event PrescriptionApproved(uint256 nonce, address patient);

    struct Prescription {
        address doctor;
        address patient;
        bytes32 prescriptionHash;
        bool approved;
    }

    modifier onlyPatient(address patientAddress) {
        require(msg.sender == patientAddress, "Only patient can call this function");
        _;
    }

    modifier onlyDoctor(address senderAddress) {
        require(isDoctor[senderAddress] == true, "Doctor is not registered");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Add a new patient
    function addPatient(address patientAddress) public onlyOwner {
        require(patientAddress != address(0), "Invalid patient address");
        patients.push(patientAddress);
        emit PatientAdded(patientAddress);
    }

    // Add a new doctor
    function addDoctor(address doctorAddress) public onlyOwner {
        require(doctorAddress != address(0), "Invalid doctor address");
        doctors.push(doctorAddress);
        isDoctor[doctorAddress] = true;
        emit DoctorAdded(doctorAddress);
    }

    // Add a new prescription
    function addPrescription(address patientAddress, bytes32 prescriptionHash) public onlyDoctor(msg.sender) {
        medicalRecords[nonce] = Prescription(msg.sender, patientAddress, prescriptionHash, false);
        doctorRecords[msg.sender].push(nonce);
        emit PrescriptionAdded(nonce, msg.sender, patientAddress);
        nonce += 1;
    }

    // Approve an existing prescription
    function approvePrescription(address patientAddress, uint256 _nonce) public onlyPatient(patientAddress) {
        Prescription storage prescription = medicalRecords[nonce];
        require(prescription.doctor != address(0), "Prescription does not exist for patient");
        require(prescription.patient == msg.sender, "You are not the patient of this prescription");
        require(prescription.approved == false, "This prescription has been approved already.");
        prescription.approved = true;
        patientRecords[patientAddress].push(_nonce);
        emit PrescriptionApproved(_nonce, patientAddress);
    }

    // Get a prescription by nonce
    function getPrescription(uint256 _nonce) public view returns (bytes32, bool) {
        Prescription storage prescription = medicalRecords[_nonce];
        return (prescription.prescriptionHash, prescription.approved);
    }
}
