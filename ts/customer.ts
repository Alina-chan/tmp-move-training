import {
  PACKAGE_ID,
  suiClient,
  getKeypair,
  ADMIN_SECRET,
} from "./config";

async function main() {
  const adminAddress = getKeypair(ADMIN_SECRET!).toSuiAddress();

  // Query the given address for all objects that a specific type.
  const emloyeeCardsRes = await suiClient.getOwnedObjects({
    owner: adminAddress,
    filter: {
      StructType: `${PACKAGE_ID}::suispresso::EmployeeCard`,
    },
    options: {
      showContent: true,
      showType: true,
    },
  });

  console.log("Objects owned by", adminAddress, ":", emloyeeCardsRes.data[0]);
  const employCard = emloyeeCardsRes.data[0] as any;

  /// How to pass the employCard object to the buy_coffee function?
  // const tx = new Transaction();
  // tx.moveCall({
  //   target: `${PACKAGE_ID}::coffee::buy_coffee`,
  //   arguments: [tx.object(employCard.objectId)],
  // });
}

main();
