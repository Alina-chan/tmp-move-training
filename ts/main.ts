import { Transaction } from "@mysten/sui/transactions";
import { PACKAGE_ID, suiClient, getKeypair, ADMIN_SECRET } from "./config";

async function main() {
  // Call the smart contract and mint a new employee card.
  try {
    console.log("Minting employee card...");
    const tx = new Transaction();

    tx.moveCall({
      target: `${PACKAGE_ID}::suispresso::new_employee_card`,
      arguments: [],
    });

    // Sign the transaction
    const res = await suiClient.signAndExecuteTransaction({
      transaction: tx,
      signer: getKeypair(ADMIN_SECRET!),
    });

    console.log(res);
  } catch (e) {
    console.log("Error occurred while minting employee card", e);
  }
}

main();
