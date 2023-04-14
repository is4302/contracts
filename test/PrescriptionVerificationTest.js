const PrescriptionVerification = artifacts.require("PrescriptionVerification");

contract("PrescriptionVerification", accounts => {
  let instance;
  const owner = accounts[0];
  const doctor = accounts[1];
  const patient = accounts[2];
  const prescriptionHash = web3.utils.sha3("Sample prescription");

  beforeEach(async () => {
    instance = await PrescriptionVerification.new({from: owner});
  });

  it("should add a doctor", async () => {
    await instance.addDoctor(doctor, {from: owner});
    const result = await instance.isDoctorRegistrated(doctor);
    assert.equal(result, true, "Doctor registration failed");
  });

  it("should add a patient", async () => {
    await instance.addPatient(patient, {from: owner});
    const result = await instance.isPatientRegistrated(patient);
    assert.equal(result, true, "Patient registration failed");
  });

  it("should add a prescription", async () => {
    await instance.addDoctor(doctor, {from: owner});
    await instance.addPatient(patient, {from: owner});
    await instance.addPrescription(patient, prescriptionHash, {from: doctor});
    const nonce = await instance.getNonceByHash(prescriptionHash);
    const result = await instance.getPrescription(nonce);
    assert.equal(result[0], prescriptionHash, "Prescription hash not saved correctly");
    assert.equal(result[1], false, "Prescription should not be approved yet");
  });

  it("should approve a prescription", async () => {
    await instance.addDoctor(doctor, {from: owner});
    await instance.addPatient(patient, {from: owner});
    await instance.addPrescription(patient, prescriptionHash, {from: doctor});
    const nonce = await instance.getNonceByHash(prescriptionHash);
    await instance.approvePrescription(patient, nonce, {from: patient});
    const result = await instance.getPrescription(nonce);
    assert.equal(result[1], true, "Prescription not approved");
  });

  it("should have correct contract owner", async () => {
    const contractOwner = await instance.getOwner(); // Use getOwner() instead of instance.owner
    assert.equal(contractOwner, owner, "Contract owner is incorrect");
  });



  it("should return the correct number of doctors and patients", async () => {
    await instance.addDoctor(doctor, {from: owner});
    await instance.addPatient(patient, {from: owner});
    const doctorCount = await instance.getNumberOfDoctors();
    const patientCount = await instance.getNumberOfPatients();
    assert.equal(doctorCount.toNumber(), 1, "Incorrect number of doctors");
    assert.equal(patientCount.toNumber(), 1, "Incorrect number of patients");
  });

  it("should return the correct record count for doctor and patient", async () => {
    await instance.addDoctor(doctor, {from: owner});
    await instance.addPatient(patient, {from: owner});
    await instance.addPrescription(patient, prescriptionHash, {from: doctor});

    const doctorRecordCount = await instance.getDoctorRecordCount(doctor);
    const patientRecordCount = await instance.getPatientRecordCount(patient);

    assert.equal(doctorRecordCount.toNumber(), 1, "Incorrect doctor record count");
    assert.equal(patientRecordCount.toNumber(), 1, "Incorrect patient record count");
  });

  it("should retrieve a prescription by nonce", async () => {
    await instance.addDoctor(doctor, {from: owner});
    await instance.addPatient(patient, {from: owner});
    await instance.addPrescription(patient, prescriptionHash, {from: doctor});
    const nonce = await instance.getNonceByHash(prescriptionHash);
    const prescription = await instance.getPrescription(nonce);
    assert.equal(prescription[0], prescriptionHash, "Prescription hash not retrieved correctly");
    assert.equal(prescription[1], false, "Prescription should not be approved yet");
  });

  it("should retrieve doctor and patient records by index", async () => {
    await instance.addDoctor(doctor, {from: owner});
    await instance.addPatient(patient, {from: owner});
    await instance.addPrescription(patient, prescriptionHash, {from: doctor});

    const doctorRecord = await instance.getDoctorRecord(doctor, 0);
    const patientRecord = await instance.getPatientRecord(patient, 0);
    const nonce = await instance.getNonceByHash(prescriptionHash);

    assert.equal(doctorRecord.toNumber(), nonce, "Doctor record not retrieved correctly");
    assert.equal(patientRecord.toNumber(), nonce, "Patient record not retrieved correctly");
  });


});




