import path from "path";
import { config } from "dotenv";
import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromB64 } from "@mysten/sui/utils";

const envPath = path.resolve(__dirname, ".env");

config({ path: envPath });

// Load the environment variables
export const ADMIN_SECRET = process.env.ADMIN_PRIVATE_KEY;
export const PACKAGE_ID = process.env.PACKAGE_ID;
export const SHARED_CASH_REGISTRY = process.env.CASH_REGISTRY;
export const SUI_NETWORK = process.env.SUI_NETWORK;
export const CUSTOMER_SECRET = process.env.CUSTOMER_PRIVATE_KEY;

// Create a new sui client instance
export const suiClient = new SuiClient({
  url: SUI_NETWORK!,
});

export function getKeypair(privateKey: string): Ed25519Keypair {
  let privateKeyArray = Array.from(fromB64(privateKey!));
  privateKeyArray.shift();
  return Ed25519Keypair.fromSecretKey(Uint8Array.from(privateKeyArray));
}
