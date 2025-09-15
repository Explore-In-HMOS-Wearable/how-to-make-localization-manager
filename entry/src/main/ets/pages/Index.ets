import { kvStoreService, utf8ByteLength } from '../pages/KVStoreService';
import { DE, EN, ES, FR, TR } from '../util/Constants';
import { WordModel } from "../model/WordModel";
import Logger from '../util/Logger';

@Entry
@Component
struct KvStoreDemo {
  // State variables
  @State storeId: string = 'Store'; // The KV store identifier
  @State keyInput: string = '';
  @State valueInput: string = '';
  @State lastResult: string = '';
  @State storeOpen: boolean = false;
  @State lang: string = 'en';
  @State words: Map<string, string> = new Map();

  // Lifecycle hook: called when component is about to appear
  async aboutToAppear() {
    Logger.info("KvStoreDemo aboutToAppear called");
    await this.ensureOpened();
    await this.loadLanguage();
    this.loadWords();
  }

  // Open the KV store if not already opened
  private async ensureOpened() {
    if (this.storeOpen) {
      Logger.debug("Store already open:", this.storeId);
      return;
    }
    try {
      await kvStoreService.openStore(this.storeId);
      this.lastResult = `Opened store: ${this.storeId}`;
      this.storeOpen = true;
      Logger.info("Store opened successfully:", this.storeId);
    } catch (e) {
      this.lastResult = `Open failed: ${JSON.stringify(e)}`;
      Logger.error("Failed to open store:", JSON.stringify(e));
    }
  }

  // Load current language from KV store
  private async loadLanguage() {
    try {
      const langVal = await kvStoreService.get('lang');
      Logger.debug("Loaded language value from store:");
      switch (langVal) {
        case '1':
          this.lang = 'en';
          break;
        case '2':
          this.lang = 'tr';
          break;
        case '3':
          this.lang = 'de';
          break;
        case '4':
          this.lang = 'fr';
          break;
        case '5':
          this.lang = 'es';
          break;
        default:
          this.lang = 'en';
      }
      Logger.info("Language set to:", this.lang);
    } catch (e) {
      this.lang = 'en';
      Logger.warn("Failed to load language, defaulting to en. Error:", JSON.stringify(e));
    }
  }

  // Load word translations for the selected language
  private loadWords() {
    Logger.debug("Loading words for language:", this.lang);
    const list: WordModel[] = this.lang === 'tr' ? TR :
      this.lang === 'de' ? DE :
        this.lang === 'fr' ? FR :
          this.lang === 'es' ? ES : EN;
    this.words.clear();
    list.forEach(w => this.words.set(w.key, w.value));
    Logger.info("Words loaded successfully for language:", this.lang);
  }

  // Main UI build method
  build() {
    Scroll() {
      Column() {
        // Title of the page
        Text(this.words.get("title"))
          .fontSize($r('app.float.title_font_size')).fontWeight(FontWeight.Medium)
          .margin({ bottom: 8, top: 24 })
          .fontColor(Color.Black)

        // Store status display
        Text(`${this.words.get("storeStatus")}: ${this.storeId} — ${this.storeOpen ? this.words.get("storeOpen") :
        this.words.get("storeClosed")}`)
          .fontSize($r('app.float.page_text_font_size')).margin({ bottom: 10 })
          .fontColor(Color.Black)

        // MANUAL LANGUAGE SWITCH BUTTONS
        // Each button changes the app language individually
        Row({ space: 2 }) {
          Button("EN")
            .onClick(async () => {
              this.lang = 'en';
              await kvStoreService.put('lang', '1');
              this.loadWords();
              Logger.info("Language switched to EN");
            })
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .width('%10')
            .backgroundColor(this.lang === 'en' ?
            $r('app.color.leaf_green') :
            $r('app.color.indigo_blue'))
            .fontColor(Color.White)
            .borderRadius(6)

          Button("TR")
            .onClick(async () => {
              this.lang = 'tr';
              await kvStoreService.put('lang', '2');
              this.loadWords();
              Logger.info("Language switched to TR");
            })
            .width('%10')
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor(this.lang === 'tr' ?
            $r('app.color.leaf_green') :
            $r('app.color.indigo_blue'))
            .fontColor(Color.White)
            .borderRadius(6)

          Button("DE")
            .onClick(async () => {
              this.lang = 'de';
              await kvStoreService.put('lang', '3');
              this.loadWords();
              Logger.info("Language switched to DE");
            })
            .width('%10')
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor(this.lang === 'de' ?
            $r('app.color.leaf_green') :
            $r('app.color.indigo_blue'))
            .fontColor(Color.White)
            .borderRadius(6)

          Button("FR")
            .onClick(async () => {
              this.lang = 'fr';
              await kvStoreService.put('lang', '4');
              this.loadWords();
              Logger.info("Language switched to FR");
            })
            .width('%10')
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor(this.lang === 'fr' ?
            $r('app.color.leaf_green') :
            $r('app.color.indigo_blue'))
            .fontColor(Color.White)
            .borderRadius(6)

          Button("ES")
            .onClick(async () => {
              this.lang = 'es';
              await kvStoreService.put('lang', '5');
              this.loadWords();
              Logger.info("Language switched to ES");
            })
            .width('%10')
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor(this.lang === 'es' ?
            $r('app.color.leaf_green') :
            $r('app.color.indigo_blue'))
            .fontColor(Color.White)
            .borderRadius(6)
        }.margin({ bottom: 8 })

        // Store control buttons: Open / Close and Delete
        Row({ space: 8 }) {
          Button(this.words.get("close") || this.words.get("open"))
            .onClick(async () => {
              if (this.storeOpen) {
                try {
                  await kvStoreService.closeStore();
                  this.storeOpen = false;
                  this.lastResult = this.words.get("storeClosed")!;
                  Logger.info("Store closed successfully");
                } catch (e) {
                  this.lastResult = `Close failed: ${JSON.stringify(e)}`;
                  Logger.error("Close store failed:", JSON.stringify(e));
                }
              } else {
                await this.ensureOpened();
              }
            })
            .fontSize($r('app.float.body_font_size'))
            .height(24)
            .backgroundColor($r('app.color.accent_orange'))
            .fontColor(Color.White)

          Button(this.words.get("deleteStore"))
            .onClick(async () => {
              try {
                await kvStoreService.deleteStore();
                this.storeOpen = false;
                this.lastResult = this.words.get("deleteStore")!;
                Logger.info("Store deleted successfully");
              } catch (e) {
                this.lastResult = `Delete failed: ${JSON.stringify(e)}`;
                Logger.error("Delete store failed:", JSON.stringify(e));
              }
            })
            .fontSize($r('app.float.body_font_size'))
            .height(24)
            .backgroundColor($r('app.color.danger_red'))
            .fontColor(Color.White)
        }.margin({ bottom: 8 })

        // Key input field
        Text(this.words.get("key"))
          .fontSize($r('app.float.page_text_font_size'))
          .fontColor(Color.Gray)
          .margin({ bottom: 4 })
          .width('76%')
          .textAlign(TextAlign.Start)

        TextInput({ text: this.keyInput })
          .onChange(v => this.keyInput = v)
          .fontSize($r('app.float.page_text_font_size'))
          .margin({ bottom: 12, left: 24, right: 24 })
          .height(24)
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .borderRadius(4)

        // Value input field
        Text(this.words.get("value"))
          .fontSize($r('app.float.page_text_font_size'))
          .fontColor(Color.Gray)
          .margin({ bottom: 4 })
          .width('76%')
          .textAlign(TextAlign.Start)

        TextInput({ text: this.valueInput })
          .onChange(v => this.valueInput = v)
          .fontSize($r('app.float.page_text_font_size'))
          .margin({ bottom: 12, left: 24, right: 24 })
          .height(24)
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .borderRadius(4)

        // Action buttons: PUT, GET, DELETE
        Row({ space: 6 }) {
          Button(this.words.get("put"))
            .onClick(async () => {
              Logger.debug("PUT clicked with key:", this.keyInput, "value:", this.valueInput);
              try {
                const keyBytes = utf8ByteLength(this.keyInput);
                if (keyBytes > 1024) {
                  Logger.error("Key too large:", keyBytes.toString());
                  throw new Error(`Key too large: ${keyBytes} bytes`);
                }
                await kvStoreService.put(this.keyInput, this.valueInput);
                this.lastResult = `PUT ok key="${this.keyInput}"`;
                Logger.info("PUT successful for key:", this.keyInput);
              } catch (e) {
                this.lastResult = `PUT failed: ${JSON.stringify(e)}`;
                Logger.error("PUT failed:", JSON.stringify(e));
              }
            })
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor($r('app.color.indigo_blue'))
            .fontColor(Color.White)
            .borderRadius(4)

          Button(this.words.get("get"))
            .onClick(async () => {
              Logger.debug("GET clicked for key:", this.keyInput);
              try {
                const data = await kvStoreService.get(this.keyInput);
                this.lastResult = `GET ok value=${data === undefined ? 'undefined' : data}`;
                Logger.info("GET successful key:", this.keyInput);
              } catch (e) {
                this.lastResult = `GET failed: ${JSON.stringify(e)}`;
                Logger.error("GET failed:", JSON.stringify(e));
              }
            })
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor($r('app.color.leaf_green'))
            .fontColor(Color.White)
            .borderRadius(4)

          Button(this.words.get("del"))
            .onClick(async () => {
              Logger.debug("DELETE clicked for key:", this.keyInput);
              try {
                await kvStoreService.delete(this.keyInput);
                this.lastResult = 'DELETE ok';
                Logger.info("DELETE successful for key:", this.keyInput);
              } catch (e) {
                this.lastResult = `DELETE failed: ${JSON.stringify(e)}`;
                Logger.error("DELETE failed:", JSON.stringify(e));
              }
            })
            .fontSize($r('app.float.small_text_font_size'))
            .height(24)
            .backgroundColor($r('app.color.rose_pink'))
            .fontColor(Color.White)
            .borderRadius(4)
        }.margin({ bottom: 16 })

        // Log display
        Text(this.words.get("result"))
          .fontSize($r('app.float.body_font_size'))
          .margin({ bottom: 4 })
          .fontColor(Color.Black)

        Text(this.lastResult)
          .fontSize($r('app.float.body_font_size'))
          .maxLines(6)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .backgroundColor(Color.Brown)
          .fontColor(Color.White)
          .padding(8)
          .margin({ bottom: 8, top: 8 })
          .borderRadius(6)
          .width('60%')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding(12)
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .backgroundColor($r('app.color.page_background'))
  }
}