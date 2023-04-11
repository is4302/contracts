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
        patientRecords[patientAddress].push(nonce);
        emit PrescriptionAdded(nonce, msg.sender, patientAddress);
        nonce += 1;
    }

    // Approve an existing prescription
    function approvePrescription(address patientAddress, uint256 _nonce) public onlyPatient(patientAddress) {
        Prescription storage prescription = medicalRecords[_nonce];
        require(prescription.doctor != address(0), "Prescription does not exist for patient");
        require(prescription.patient == msg.sender, "You are not the patient of this prescription");
        require(prescription.approved == false, "This prescription has been approved already.");
        prescription.approved = true;
        emit PrescriptionApproved(_nonce, patientAddress);
    }

    // Get a prescription by nonce
    function getPrescription(uint256 _nonce) public view returns (bytes32, bool) {
        Prescription storage prescription = medicalRecords[_nonce];
        return (prescription.prescriptionHash, prescription.approved);
    }

    // Getter functions for medical records
    function getPrescriptionDoctor(uint256 _nonce) public view returns (address) {
        Prescription storage prescription = medicalRecords[_nonce];
        return prescription.doctor;
    }

    function getPrescriptionPatient(uint256 _nonce) public view returns (address) {
        Prescription storage prescription = medicalRecords[_nonce];
        return prescription.patient;
    }

    function getPrescriptionHash(uint256 _nonce) public view returns (bytes32) {
        Prescription storage prescription = medicalRecords[_nonce];
        return prescription.prescriptionHash;
    }

    function isPrescriptionApproved(uint256 _nonce) public view returns (bool) {
        Prescription storage prescription = medicalRecords[_nonce];
        return prescription.approved;
    }

    // Getter functions for doctor and patient records
    function getDoctorRecord(address doctorAddress, uint256 index) public view returns (uint256) {
        require(isDoctor[doctorAddress], "Doctor is not registered");
        return doctorRecords[doctorAddress][index];
    }

    function getPatientRecord(address patientAddress, uint256 index) public view returns (uint256) {
        return patientRecords[patientAddress][index];
    }

    function getDoctorRecordCount(address doctorAddress) public view returns (uint256) {
        require(isDoctor[doctorAddress], "Doctor is not registered");
        return doctorRecords[doctorAddress].length;
    }

    function getPatientRecordCount(address patientAddress) public view returns (uint256) {
        return patientRecords[patientAddress].length;
    }

    // Getter functions for patients and doctors arrays
    function getPatient(uint256 index) public view returns (address) {
        require(index < patients.length, "Index out of range");
        return patients[index];
    }

    function getDoctor(uint256 index) public view returns (address) {
        require(index < doctors.length, "Index out of range");
        return doctors[index];
    }

    function getPatientCount() public view returns (uint256) {
        return patients.length;
    }

    function getDoctorCount() public view returns (uint256) {
        return doctors.length;
    }
}