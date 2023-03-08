// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/access/AccessControl.sol";

contract MedRecChain is AccessControl {

    //ROLES
    bytes32 public constant ADMIN_ROLE= keccak256("ADMIN_ROLE");
    bytes32 public constant HOSPITAL_ROLE= keccak256("HOSPITAL_ROLE");
    bytes32 public constant DOCTOR_ROLE= keccak256("DOCTOR_ROLE");
    bytes32 public constant PATIENT_ROLE= keccak256("PATIENT_ROLE");
    bytes32 public constant REQUESTER_ROLE= keccak256("REQUESTER_ROLE");

    
    // Admin refers to government, It hard coded by us.
    address public Admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    


    struct Hospital
    {
        uint256 id;
        string name;
        string place;
        address addr;
    }

    mapping(address=>Hospital) Hospitals;

     
    // for Ids
    uint256 Hospital_index;
    uint256 Doctor_index;
    uint256 Patient_index;
    
    
    

    //EVENTS
    event HospitalAdded(address indexed Hospital_Address); //by admin
    event HospitalRemoved(address indexed Hospital_Address); //by admin
    event DoctorAdded(address indexed Doctor_Address); //by hospital
    event DoctorRemoved(address indexed Doctor_Address);  //by hospital
    event DoctorUpdata(address indexed Doctor_Address);  //by hospital
    event PatientAdded(address indexed Patient_Address);  //by hospital
    event PatientUpdated(address indexed Patient_Address); //by patient
    event AccessGranted(address indexed Doctor_Address, address indexed Patient_Address); //by patient 
    event AccessRejected(address indexed Doctor_Address, address indexed Patient_Address); //by patient
    event RequestAccess(address indexed requester, address indexed patient); //by doctor or (patient) 

    constructor() {
         _setupRole(ADMIN_ROLE,Admin);
    }


    //To check the role of who deploye the contract. 
    modifier onlyAdmin(){ 
        require(hasRole(ADMIN_ROLE, msg.sender),"Only superAdmin has permission to do that action");
        _;
    }

    modifier onlyHospital(){
        require(hasRole(HOSPITAL_ROLE, msg.sender), "This account is not Admin");
        _;
    }
    modifier onlydoctors(){
        require(hasRole(DOCTOR_ROLE, msg.sender), "This account is not Doctor");
        _;
    }
    modifier onlypatient(){
         require(hasRole(PATIENT_ROLE, msg.sender), "This account is not patient");
        _;
    
    }



//////////////////////////////////////

//Tasks done by Admin (defult exisit)
//1. add hospital
//2. delete hospital


    function addhospital(string memory _name, string memory _place,address _address) public onlyAdmin returns(bool success){
        require(!hasRole(HOSPITAL_ROLE, _address), "This hospital is really exisit!! ");
         _setupRole(HOSPITAL_ROLE, _address);
        Hospital_index= Hospital_index+1;
        Hospitals[_address]=Hospital(Hospital_index,_name,_place,_address); 
        emit HospitalAdded(_address);
        return true;
    }

    function removehospital(address _address) public onlyAdmin returns(bool success){
        require(hasRole(HOSPITAL_ROLE, _address), "This hospital is not exisit");
        _revokeRole(HOSPITAL_ROLE,_address);
        delete Hospitals[_address];
        emit HospitalRemoved(_address);
        return true;
    }

///////////////////////////////////////////

// Tasks done by Hospitals (sign in )
//1. add doctor
//2. updata doctor
//3. delete doctor
//4. add patient

    struct record {

        uint Medical_id;
        address doctor_addr;
        address patients_addr;
        string rec_name;
        string category;
        string Created_at;
        string hex_ipfs;

       // bool isApproved;
        
    }

    mapping(address=>record) Records;
    

    struct patient
    {

        uint256 id;
        // string name;
        // string gender;
        // string email;
        // uint phone;
        //  uint256 National_id;
        // uint256 age;
        // string bloodgroup;
        // string marital_status
        address addr;
        
    }

    mapping(address=>patient) patients;

    struct doctor{

        uint256 id;
        // string name;
        // string gender;
        // string email;
        // uint phone;
        // uint256 National_id;
        // uint256 age;
        // string Medical_specialty;
        address addr;
        
    }

    mapping(address=>doctor) doctors;





    function addDoctor(address _docAddress) public onlyHospital returns(bool success){
        require(!hasRole(DOCTOR_ROLE, _docAddress), "This account already a doctor");
        _setupRole(DOCTOR_ROLE, _docAddress);
        Doctor_index= Doctor_index+1;
        doctors[_docAddress]=doctor(Doctor_index,_docAddress); 
        emit DoctorAdded(_docAddress);
        return true;
    }

    function updataDoctor(address _docAddress) public onlyHospital returns(bool success){
        require(hasRole(DOCTOR_ROLE, _docAddress), "This account not exisit ");
        uint _index = doctors[_docAddress].id;
        doctors[_docAddress]=doctor(_index,_docAddress); 
        emit DoctorUpdata(_docAddress);
        return true;
    }


    function removeDoctor(address _docAddress) public onlyHospital returns(bool success){
        require(hasRole(DOCTOR_ROLE, _docAddress),"This account not exisit");
         delete doctors[_docAddress];
        _revokeRole(DOCTOR_ROLE,_docAddress);
        emit DoctorRemoved(_docAddress);
        return true;
    }


    function addPatient(address _PatientAddress) public onlyHospital returns(bool success){
        require(!hasRole(PATIENT_ROLE, _PatientAddress), "This account already a patient");
        _setupRole(PATIENT_ROLE, _PatientAddress);
        Patient_index= Patient_index+1;
        patients[_PatientAddress]=patient(Patient_index,_PatientAddress); 
        emit PatientAdded(_PatientAddress);
        return true;
    }

//////////////////////////////////////////////

//Tasks done by Doctor (sign in)

//1. send request to patient
//2. see record (has be accepted)
//3. add record (has be accepted)
//4.view his profile info
//5.updata his personal info
//6.show requests by id & show their status





//Suggestion
    struct request
    {
        uint id;
        address from_doctor_addr;
        address to_patients_addr;
        bool isApproved;

    }
       mapping(address=>request) requests;



    function requestAccess(address _patient) public onlydoctors returns(bool success) {
        _setupRole(REQUESTER_ROLE, msg.sender);
        emit RequestAccess(msg.sender, _patient);
        return true;
    }



    function addRecord() onlydoctors  public{

    }

    function SeeRecordforDoctor()  public{

    }



///////////////////////////////////

//Tasks done by Patient (sign in)

//1.view his all records
//2.accept request sended by doctor
//3.rejected request sended by doctor
//4.give permission to doctor bt himself
//5.see requestes from doctors
//6.view his profile info
//7.updata his personal info
//8.show specific record by id

    function approveAccess(address _doctor) onlypatient  public {
        require(hasRole(PATIENT_ROLE, msg.sender), "he/she is not a patient");
        require(hasRole(DOCTOR_ROLE, _doctor), "this acount is not a doctor ");
        require(hasRole(REQUESTER_ROLE, _doctor), "this acount does not send request ");
        revokeRole(REQUESTER_ROLE, _doctor);
       // Records[msg.sender].isApproved = true;
        emit AccessGranted(_doctor, msg.sender);
    }

    function rejectAccess(address _doctor) onlypatient public {
        require(hasRole(PATIENT_ROLE, msg.sender), "Caller is not a patient");
        require(hasRole(DOCTOR_ROLE, _doctor), "Doctor does not have the doctor role");
        require(hasRole(REQUESTER_ROLE, _doctor), "this acount does not send request ");
        revokeRole(REQUESTER_ROLE, _doctor);
       // Records[msg.sender].isApproved = false;
        emit AccessRejected(_doctor, msg.sender);
    }


    function getallRecordbyAddress(address _patient) onlypatient public {


    }


    function updatePatient(address _PatientAddress) public onlypatient returns(bool success){
        require(hasRole(PATIENT_ROLE, msg.sender), "This account already a patient");
        uint _index = patients[_PatientAddress].id;
        patients[_PatientAddress]=patient(_index,_PatientAddress); 
        emit PatientUpdated(_PatientAddress);
        return true;
    }
    







}