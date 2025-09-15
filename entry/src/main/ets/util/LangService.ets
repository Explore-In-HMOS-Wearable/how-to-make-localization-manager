import { WordModel } from "../model/WordModel";
import { EN, TR } from "./Constants";

export class LangService {
  private lang: string = "en";
  private words: Map<string, string> = new Map();

  constructor(defaultLang: string = "en") {
    this.setLang(defaultLang);
  }

  setLang(lang: string) {
    this.lang = lang;
    let list: WordModel[] = lang === "tr" ? TR : EN;
    this.words.clear();
    list.forEach(w => this.words.set(w.key, w.value));
  }

  getLang(): string {
    return this.lang;
  }

  t(key: string): string {
    return this.words.get(key) ?? key;
  }
}

export const langService: LangService = new LangService("en");
