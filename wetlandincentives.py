from web3 import Web3,HTTPProvider
import json
import random
import time
from eth_account import Account
account_address = '0x77e7c143650c509cb047899a1d78a9b0efbbda51'
blockchain_address = 'http://127.0.0.1:9545'

client= Web3(HTTPProvider(blockchain_address))
client.eth.defaultAccount = client.eth.accounts[0]
print(client.eth.defaultAccount)
compiled_contract_path = f'F:/MTech_Files/Minor_Thesis/truffle/build/contracts/wetland_monitoring.json'
deployed_contract_address = '0xa13fDe1e10Fe604b676A30DA18c32dE0a36689EC'
with open(compiled_contract_path) as file:
    contract_json = json.load(file)
    contract = client.eth.contract(address=deployed_contract_address, abi=contract_json)
    a=contract.functions.sethresholds(8,8,25,60,1000).call()
    #b=contract.functions.addRecord().call()
    c=contract.functions.incentivemultiplier(1,2).call()

def gensensordata():
        pH=random.uniform(1.0,14.0)
        DO=random.uniform(4.0,8.0)
        turb=random.uniform(10.0,100.0)
        SM=random.uniform(10.0,100.0)
        tds=random.uniform(10.0,1000.0)
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

def main():
     activity, status = add_observation()
     print('Observation recorded')
     activity=input('Enter your observation:')
     data= gensensordata()
     print('Sensor Data', data)

if __name__ == "__main__":
    main()
