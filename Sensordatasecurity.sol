pragma solidity ^0.8.0;

contract SensorDataIntegrity{
   address public owner;
   mapping(address => bool) public authorizedSensors;//indicates whether the sensor is authorized or not by checking the address
   mapping(address => bytes32) sensorDataId;//Maps the sensor data Id to 32 byte address 
   mapping(address => bytes) encryptedSensorData;

    event SensorAuthorized(address indexed sensor);
    event SensorDataStored(address indexed sensor, bytes32 dataId);

    constructor() 
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can authorize sensors.");
        _;
    }
//Function to authorize the sensor
     function authorizeSensor(address sensorAddress) external onlyOwner 
     {
        require(sensorAddress != address(0), "Invalid sensor address.");
        require(!authorizedSensors[sensorAddress], "Sensor is already authorized.");
        
        authorizedSensors[sensorAddress] = true;
        emit SensorAuthorized(sensorAddress);
    }
//Function to validate whether a sensor is authorized or not
    function sensorvalidation(address sensorAddress) external view returns (bool) 
    {
        return authorizedSensors[sensorAddress];
    }
//Function to store the data recieved from the sensors
     function storeSensorData(bytes32 dataId, bytes memory encryptedData) public 
     {
        sensorDataId[msg.sender] = dataId;
        encryptedSensorData[msg.sender] = encryptedData;
        emit SensorDataStored(msg.sender, dataId);
    }

//Function to verify whether the sensor data is valid or not 

    function verifySensorData(address sensor, bytes32 dataId) public view returns (bool) 
    {
        return sensorDataId[sensor] == dataId;
    }
      
}
