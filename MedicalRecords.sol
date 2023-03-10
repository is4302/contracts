pragma solidity ^0.8.0;



contract PrescriptionVerification {
    address[] public patients; // patient address -> hash of patient stored in DB / or simply store them as a set
    address[] public doctors;
    mapping (address => bool) isDoctor;
    mapping (address=>uint256[]) doctorRecords;
    mapping (address=>uint256[]) patientRecords;
    mapping (uint256=>Prescription) private medicalRecords;
    address owner;
    uint256 nonce = 0;
    

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
        require(patientAddress != address(0), "Invalid Doctor Address");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addPatient(address patientAddress) public {
        require(patientAddress != address(0), "Invalid patient address");
        patients.push(patientAddress);
    }

    function addDoctor(address doctorAddress, bytes  memory publicKey) public onlyOwner {
        require(doctorAddress != address(0), "Invalid doctor address");
        doctors.push(doctorAddress);
    }

    function addPrescription(address patientAddress, bytes32 prescriptionHash) public onlyDoctor(msg.sender) {
        medicalRecords[nonce] = Prescription(msg.sender, patientAddress, prescriptionHash, false);
        doctorRecords[msg.sender].push(nonce);
        nonce += 1;
    }

    function approvePrescription(address patientAddress, uint256 nonce) public onlyPatient(patientAddress) {
        Prescription storage prescription = medicalRecords[nonce];
        require(prescription.doctor != address(0), "Prescription does not exist for patient");
        require(prescription.patient == msg.sender, "You are not the patient of this prescription");
        require(prescription.approved == false, "This prescription has been proved already.");
        prescription.approved = true;
        patientRecords[patientAddress].push(nonce);

    }

    function getPrescription(uint256 nonce) public view returns (bytes32, bool) {
        Prescription storage prescription = medicalRecords[nonce];
        return (prescription.prescriptionHash, prescription.approved);
    }


}
