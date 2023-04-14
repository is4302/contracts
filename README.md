# Prescription Verification Smart Contract

This repository contains a smart contract for prescription verification in a healthcare system. The smart contract is written in Solidity and deployed on the Ethereum network. It allows doctors to create prescription records and patients to approve them.

## Structure

The repo is organized as follows:

- `contracts/` - Contains the main smart contract file `PrescriptionVerification.sol`.
- `migrations/` - Contains migration files for deploying the smart contract on the Ethereum network.
- `test/` - Contains unit tests for the smart contract.
- `LICENSE` - License information for the project.
- `README.md` - This file, providing a brief overview of the project.
- `truffle-config.js` - Configuration file for the Truffle framework.

## Getting Started

To get started with this project, follow these steps:

1. Clone the repository:

``git clone https://github.com/is4302/contracts.git``


2. Change into the `contracts/` directory:

``cd contracts``


3. Install dependencies:

``npm install``


4. Compile the smart contract:

``truffle compile``


5. Deploy the smart contract to a local development network:

``truffle develop``


6. Run tests:

``truffle test``


## Smart Contract Overview

The `PrescriptionVerification` smart contract has the following main components:

- **Patients and Doctors**: Patients and doctors are represented as Ethereum addresses. The smart contract keeps track of registered patients and doctors using arrays and mapping.
- **Prescription Records**: Prescription records are stored in a struct containing the doctor's address, patient's address, prescription hash, and approval status.
- **Access Control**: The smart contract has various access control modifiers to ensure that only the appropriate parties can perform specific actions.

The smart contract also emits events when patients are added, doctors are added, prescriptions are created, and prescriptions are approved.

## Contributing

Feel free to fork the repository and submit pull requests with any improvements or bug fixes. If you encounter any issues, please report them in the GitHub issue tracker.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more information.
