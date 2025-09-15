import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';


/**
 * Thin wrapper around callback-style ArkData Distributed KV APIs using Promises.
 * Handles: createKVManager, getKVStore, put/get/delete, close/delete store.
 * NOTE: Do NOT mutate UI directly inside callbacks; call from UI with await.
 */
export class KVStoreService {
  private kvManager?: distributedKVStore.KVManager;
  private kvStore?: distributedKVStore.SingleKVStore;
  private appId = ''; // bundleName
  private storeId = '';

  /** Initialize manager once with app context + bundle. */
  init(context: Context, bundleName: string) {
    if (this.kvManager) {
      return;
    }
    this.appId = bundleName;
    const cfg: distributedKVStore.KVManagerConfig = { context, bundleName };
    try {
      this.kvManager = distributedKVStore.createKVManager(cfg);
      console.info('[KV] KVManager created');
    } catch (e) {
      const err = e as BusinessError;
      console.error(`[KV] createKVManager failed code=${err.code} msg=${err.message}`);
    }
  }

  /** Open (or create) a SINGLE_VERSION device-local KV store. */
  async openStore(storeId: string): Promise<void> {
    if (!this.kvManager) {
      throw new Error('KVManager not initialized');
    }
    this.storeId = storeId;
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: true,
      autoSync: false,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S3,
    };
    await new Promise<void>((resolve, reject) => {
      try {
        this.kvManager!.getKVStore<distributedKVStore.SingleKVStore>(storeId, options,
          (err, store) => {
            if (err) {
              reject(err);
              return;
            }
            this.kvStore = store;
            console.info('[KV] Store opened');
            resolve();
          });
      } catch (e) {
        reject(e);
      }
    });
  }

  /** Close current store. */
  async closeStore(): Promise<void> {
    if (!this.kvManager || !this.storeId) {
      return;
    }
    await new Promise<void>((resolve, reject) => {
      try {
        this.kvStore = undefined;
        this.kvManager!.closeKVStore(this.appId, this.storeId, (err: BusinessError) => {
          if (err) {
            reject(err);
            return;
          }
          console.info('[KV] Store closed');
          resolve();
        });
      } catch (e) {
        reject(e);
      }
    });
  }

  /** Permanently delete current store. */
  async deleteStore(): Promise<void> {
    if (!this.kvManager || !this.storeId) {
      return;
    }
    await new Promise<void>((resolve, reject) => {
      try {
        this.kvStore = undefined;
        this.kvManager!.deleteKVStore(this.appId, this.storeId, (err: BusinessError) => {
          if (err) {
            reject(err);
            return;
          }
          console.info('[KV] Store deleted');
          resolve();
        });
      } catch (e) {
        reject(e);
      }
    });
  }

  /** Put string/number/boolean/bytes. */
  async put(key: string, value: string | number | boolean | Uint8Array): Promise<void> {
    const store = this.requireStore();
    this.validateKeyValue(key, value);
    await new Promise<void>((resolve, reject) => {
      try {
        store.put(key, value, (err) => {
          if (err) {
            reject(err);
            return;
          }
          resolve();
        });
      } catch (e) {
        reject(e);
      }
    });
  }

  /** Get by key. */
  async get(key: string): Promise<string | number | boolean | Uint8Array | undefined> {
    const store = this.requireStore();
    return await new Promise((resolve, reject) => {
      try {
        store.get(key, (err, data) => {
          if (err) {
            reject(err);
            return;
          }
          resolve(data);
        });
      } catch (e) {
        reject(e);
      }
    });
  }

  /** Delete by key. */
  async delete(key: string): Promise<void> {
    const store = this.requireStore();
    await new Promise<void>((resolve, reject) => {
      try {
        store.delete(key, (err) => {
          if (err) {
            reject(err);
            return;
          }
          resolve();
        });
      } catch (e) {
        reject(e);
      }
    });
  }

  /** Helpers */
  private requireStore(): distributedKVStore.SingleKVStore {
    if (!this.kvStore) {
      throw new Error('KV store not opened');
    }
    return this.kvStore as distributedKVStore.SingleKVStore;
  }

  /** Constraints: key <= 1KB(=1024 bytes), value <= 4MB. */
  private validateKeyValue(key: string, value: string | number | boolean | Uint8Array) {
    const keyBytes = utf8ByteLength(key);
    if (keyBytes > 1024) {
      throw new Error(`Key exceeds 1KB: ${keyBytes} bytes`);
    }
    let valueBytes = 0;
    if (value instanceof Uint8Array) {
      valueBytes = value.byteLength;
    } else if (typeof value === 'string') {
      valueBytes =
        utf8ByteLength(value);
    } else if (typeof value === 'number' || typeof value === 'boolean') {
      valueBytes = 8;
    } // rough
    if (valueBytes > 4 * 1024 * 1024) {
      throw new Error(`Value exceeds 4MB: ${valueBytes} bytes`);
    }
  }
}

export function utf8ByteLength(str: string): number {
  let bytes = 0;
  for (let i = 0; i < str.length; i++) {
    const codePoint = str.charCodeAt(i);
    if (codePoint <= 0x7F) {
      bytes += 1;
    } else if (codePoint <= 0x7FF) {
      bytes += 2;
    } else if (codePoint >= 0xD800 &&
      codePoint <= 0xDBFF) { // surrogate pair
      i++;
      bytes += 4;
    } else {
      bytes += 3;
    }
  }
  return bytes;
}

export const kvStoreService = new KVStoreService();

