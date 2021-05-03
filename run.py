from main import Main


def main():
    ##### Required paramters by the user #######
    """
    CONTRACT_PATH --> for all contracts in folder give the address of the folder
                  --> for a specific contract give the full address of the contract including .sol at the end
    """
    CONTRACT_PATH = "./contracts/"
    GAS_LIMIT = 6721975
    FUZZER = True
    THRESHOLD = True
    REPORT_PATH = "./Results.txt"
    FUZZER_MAX_ITERATION = 10
    # solc compiler version
    solc = "0.5.3"
    
    ################################################

    ####### Modify only if required #######
    ####### Parameters for Ganache-cli ##################
    ganache = {
        "defaultBalanceEther": '1000',
        "port1": '8050',
        "port2": '8060',
        "port3": '8070',
        "host": '127.0.0.1',
        "gasLimit": hex(GAS_LIMIT)
    }

    ############## You can leave this part as it is or modify them as needed #######################
    output_folder = 'tempoutput/'
    output_file = "temp.txt"
    agent_output = 'Agenttemp.txt'
    gas_gauge_dir = "./gas_gauge_testResult"
    new_contract_name = 'gas_gauge.sol'
    ##################################

##################################################################################################################
    contract_name = ''
    if '.sol' in CONTRACT_PATH:
        contract_name = CONTRACT_PATH[CONTRACT_PATH.rfind('/') + 1:]
        CONTRACT_PATH = CONTRACT_PATH[:CONTRACT_PATH.rfind('/') + 1]
    if CONTRACT_PATH[-1] != '/':
        CONTRACT_PATH += '/'
    if output_folder[-1] != '/':
        output_folder += '/'

    solc_use = ''
    if solc != '':
        solc_use = "solc-select use " + solc + ";"


    Tool = Main(CONTRACT_PATH, contract_name, GAS_LIMIT, ganache, output_folder, output_file, agent_output,
                 gas_gauge_dir, new_contract_name, FUZZER_MAX_ITERATION, solc_use)

    Tool.run_tool(FUZZER, THRESHOLD, REPORT_PATH)




if __name__ == "__main__":
    main()
