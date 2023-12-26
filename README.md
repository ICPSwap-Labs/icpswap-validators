# Summary
The purpose of this project is to assist SNS Dao in managing the positions owned by the governance canister on ICPSwap.

# Transfer position validator
The SNS Dao can call the `transferPosition` method to transfer the position owned by the governance canister to another principal.

This validator ensures that the receiving principal is in the whitelist. You can add this canister to SNS Dao.

Only the controller and governance canister can call the `add_whitelist` and `remove_whitelist` methods to add or remove principals from the whitelist.

Only the controller can set the governance canister ID using the `set_governance_canister_id` method.

You can implement your own validation logic, as long as the validator's arguments and return values are the same.

## Build & Install
``` sh
vessel install
dfx start --background
dfx canister create --network ic TransferPositionValidator
dfx build TransferPositionValidator --network ic
dfx canister install --network ic TransferPositionValidator
```
## Proposal to register generic function
First, you need to register the `transferPosition` function of SwapPool as a GenericNervousSystemFunction, you can submit a proposal to register the GenericNervousSystemFunction as follows.
``` sh
CANISTER_IDS_FILE="./sns_canister_ids.json"
PEM_FILE=""        # The private key of the current identity.
VALIDATOR_CID=""   # The validator canister ID you just deployed.
POOL_CID=""        # The pool canister ID, you can find it on https://info.icpswap.com/swap.
NEURON_ID=""       # 
FUNC_ID="2000"     # You can define a unique function ID distinct from those of other generic nervous system functions.
FUNC_NAME="transferPosition"  
TITLE="Proposal to add generic nervous system function to transfer position."
SUMMARY=""
PROPOSAL="(record { title=\"$TITLE\"; url=\"\"; summary=\"$SUMMARY\"; action=opt variant {AddGenericNervousSystemFunction = record {id=$FUNC_ID:nat64; name=\"transferPosition\"; description=null; function_type=opt variant {GenericNervousSystemFunction=record{validator_canister_id=opt principal \"$VALIDATOR_CID\"; target_canister_id=opt principal \"$POOL_CID\"; validator_method_name=opt \"validate_transfer_position\"; target_method_name=opt \"transferPosition\"}}}}})"

quill sns  \
   --canister-ids-file $CANISTER_IDS_FILE  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "$PROPOSAL" \
   $NEURON_ID > msg.json
 
quill send msg.json
```
## Proposal to execute generic function
You can submit a proposal to transfer the position owned by the governance canister in SwapPool as follows.
``` sh
CANISTER_IDS_FILE="./sns_canister_ids.json"
PEM_FILE=""       # The private key of the current identity.
FUNC_ID="2000"    # The generic function ID defined above.
GOV_CID=""        # The governance canister ID.
TO_PRINCIPAL=""   # The principal you want to transfer to.
POSITION_ID=""    # The position ID you want to transfer. You can find your position on https://info.icpswap.com/swap-scan/positions
NEURON_ID=""      # 
TITLE=""          
SUMMARY=""
ARGS="$(didc encode --format blob "(principal \"$GOV_CID\", principal \"$TO_PRINCIPAL\", $POSITION_ID)")"
PROPOSAL="(record { title=\"$TITLE\"; url=\"\"; summary=\"$SUMMARY\"; action=opt variant {ExecuteGenericNervousSystemFunction = record {function_id=$FUNC_ID:nat64; payload=$ARGS}}})"

quill sns  \
   --canister-ids-file $CANISTER_IDS_FILE \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "$PROPOSAL" \
   $NEURON_ID > msg.json
quill send msg.json
```
