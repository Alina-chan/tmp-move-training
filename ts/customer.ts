import { Transaction } from "@mysten/sui/transactions";
import {
  PACKAGE_ID,
  suiClient,
  getKeypair,
  CUSTOMER_SECRET,
  SHARED_CASH_REGISTRY,
} from "./config";

async function main() {
  const customerAddress = getKeypair(CUSTOMER_SECRET!).toSuiAddress();

  // Query the given address for all objects that a specific type.
  const membershipCardsRes = await suiClient.getOwnedObjects({
    owner: customerAddress,
    filter: {
      StructType: `${PACKAGE_ID}::membership::MembershipCard`,
    },
    options: {
      showContent: true,
      showType: true,
    },
  });

  const membershipCard = membershipCardsRes.data[0] as any;

  const tx = new Transaction();

  // Splitting a coin based on the coffee's price
  const [coin] = tx.splitCoins(tx.gas, [100]);

  const [coffee] = tx.moveCall({
    target: `${PACKAGE_ID}::coffee::buy_coffee`,
    arguments: [
      tx.object(membershipCard.data.objectId),
      tx.pure.string("Americano"),
      tx.pure.u8(5),
      tx.pure.u64(100),
      tx.pure.bool(true),
      coin,
      tx.object(SHARED_CASH_REGISTRY!),
      tx.pure.string(
        "https://images.squarespace-cdn.com/content/v1/5a7cbe247131a5f17b3cc8fc/1519447742018-MOHBW2G0VOQ7QSCPJE14/Americano-Coffee-Lounge-Ingredients.jpg?format=2500w"
      ),
    ],
  });

  // Add milk as dynamic field
  tx.moveCall({
    target: `${PACKAGE_ID}::coffee::add_milk`,
    arguments: [coffee],
  });

  // Add sugar twice
  tx.moveCall({
    target: `${PACKAGE_ID}::coffee::add_sugar`,
    arguments: [coffee],
  });

  tx.moveCall({
    target: `${PACKAGE_ID}::coffee::add_sugar`,
    arguments: [coffee],
  });

  tx.moveCall({
    target: `${PACKAGE_ID}::coffee::add_cup`,
    arguments: [coffee, tx.pure.string("paper")],
  });

  // Transfer coffee to the customer
  tx.transferObjects([coffee], customerAddress);

  // Sign the transaction
  const res = await suiClient.signAndExecuteTransaction({
    transaction: tx,
    signer: getKeypair(CUSTOMER_SECRET!),
    options: {
      showEffects: true,
      showObjectChanges: true,
    },
  });
  console.log(res);
}

main();
