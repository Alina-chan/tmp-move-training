import { Transaction } from "@mysten/sui/transactions";
import { PACKAGE_ID, suiClient, getKeypair, ADMIN_SECRET } from "./config";

async function main() {
  // Call the smart contract and mint a new membership card.
  try {
    const tx = new Transaction();
    const adminAddress = getKeypair(ADMIN_SECRET!).getPublicKey().toSuiAddress()

    const [employeeCard, hotPotato] = tx.moveCall({
        target: `${PACKAGE_ID}::suispresso::new_employee_card`,
        arguments: [],
      });
  
      tx.moveCall({
        target: `${PACKAGE_ID}::membership::new_card`,
        arguments: [
          employeeCard,
          tx.pure.string("Dionisis"),
          tx.pure.address(adminAddress)
        ],
        //typeArguments:[`${PACKAGE_ID}::x::x`]
      });

      //tx.transferObjects([employeeCard], adminAddress)
      tx.moveCall({
        target: `${PACKAGE_ID}::suispresso::transfer_employee_card`,
        arguments: [
          hotPotato,
          employeeCard
        ],
      });

    // Sign the transaction
    const res = await suiClient.signAndExecuteTransaction({
      transaction: tx,
      signer: getKeypair(ADMIN_SECRET!),
      options: {
        showEffects: true,
        showObjectChanges: true,
      },
    });

    console.log(res);
  } catch (e) {
    console.log("Error occurred while minting membership card", e);
  }
}

main();