from web3 import Web3,HTTPProvider
import json
import random
import math
import time
from eth_account import Account
account_address = '0x77e7c143650c509cb047899a1d78a9b0efbbda51'
blockchain_address = 'http://127.0.0.1:9545'

client= Web3(HTTPProvider(blockchain_address))
client.eth.defaultAccount = client.eth.accounts[0]
# print(client.eth.defaultAccount)
compiled_contract_path = f'F:/MTech_Files/Minor_Thesis/truffle/build/contracts/wetland_monitoring.json'
deployed_contract_address = '0xa13fDe1e10Fe604b676A30DA18c32dE0a36689EC'
with open(compiled_contract_path) as file:
    contract_json = json.load(file)
    contract = client.eth.contract(address=deployed_contract_address, abi=contract_json)

def gensensordata():
        pH=random.uniform(1.0,14.0)
        DO=random.uniform(1.0,8.0)
        turb=random.uniform(10.0,100.0)
        SM=random.uniform(10.0,100.0)
        tds=random.uniform(10.0,300.0)
        sensor_data={
            'pH':pH,
            'dissolvedoxygen':DO,
            'turbidity':turb,
            'soil moisture':SM,
            'totaldissolvedsolvents':tds,
            'timestamp':time.time()
            }
        return sensor_data

def add_observation():
    input_status=input('Is the wetland polluted? (yes/no):').lower()
    if input_status=='yes':
        activity=input('Enter your observation:')
        status=1
        return activity, status
    elif input_status=='no':
        status=0
        activity=input('Enter your observation:')
        return activity, status
    else:
        activity=0
        status=0
        print('Invalid input')
        return activity, status
    
def validateobservation(status):
     pH_threshold=range(6,8)
     DO_threshold=range(4,8)
     turb_threshold=range(25,50)
     sm_threshold=range(60,100)
     tds_threshold=range(50,250)
     validate=gensensordata()
     add= status
     if(validate['pH']<= pH_threshold.start<= pH_threshold.stop-1
        or validate['dissolvedoxygen']<= DO_threshold.start<=DO_threshold.stop-1
        or validate['turbidity']<= turb_threshold.start<=DO_threshold.stop-1 
        or validate['soil moisture']<= sm_threshold.start<=sm_threshold.stop-1
        or validate['totaldissolvedsolvents'] <= tds_threshold.start<=tds_threshold.stop-1
        and add['status']==0):
          flag=1
          print('Observation Recorded is correct!!')
          return flag
     elif(validate['pH']> pH_threshold.start<=pH_threshold.stop-1
        or validate['DO']> DO_threshold.start<=DO_threshold.stop-1 
        or validate['turb']> turb_threshold.start<=turb_threshold.stop-1
        or validate['SM']> sm_threshold.start<=sm_threshold.stop-1
        or validate['tds']> tds_threshold.start<=tds_threshold.stop-1
        and add['status']==1): 
          flag=1
          #print('Observation recorded is correct!!')
          return flag
     else:
          flag=0
          print('Invalid Observation')
          return flag
          
          
def reward(stat):
     validobs=validateobservation(stat)
     print('Checking if eligible for Reward....')
     if(validobs == 1):
       r=contract.functions.claimReward().transact({'from': client.eth.defaultAccount}) 
       print('Congrats!!! User Rewarded')
     elif(validobs == 0):
          print('Better Luck Next Time')
     else:
          print('Unknown Error') 
          
def main():
     activity, status = add_observation()
     data= gensensordata()
     print('Sensor Data', data)
     valid=validateobservation(status)
     Rew=reward(status)

if __name__ == "__main__":
    main()


