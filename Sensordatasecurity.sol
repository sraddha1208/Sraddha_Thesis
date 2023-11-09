pragma solidity ^0.8.0;

contract SensorDataIntegrity{
   address public owner;
   mapping(address => bool) public authorizedSensors;
   mapping(address => bytes32) sensorDataId;
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
     function authorizeSensor(address sensorAddress) external onlyOwner 
     {
        require(sensorAddress != address(0), "Invalid sensor address.");
        require(!authorizedSensors[sensorAddress], "Sensor is already authorized.");
        
        authorizedSensors[sensorAddress] = true;
        emit SensorAuthorized(sensorAddress);
    }
    function sensorvalidation(address sensorAddress) external view returns (bool) 
    {
        return authorizedSensors[sensorAddress];
    }
     function storeSensorData(bytes32 dataId, bytes memory encryptedData) public 
     {
        sensorDataId[msg.sender] = dataId;
        encryptedSensorData[msg.sender] = encryptedData;
        emit SensorDataStored(msg.sender, dataId);
    }

    function verifySensorData(address sensor, bytes32 dataId) public view returns (bool) 
    {
        return sensorDataId[sensor] == dataId;
    }
      
}
