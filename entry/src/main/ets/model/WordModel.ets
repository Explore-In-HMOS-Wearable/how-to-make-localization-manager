export class WordModel {
  langId: number;
  key: string;
  value: string;

  constructor(langId: number, key: string, value: string) {
    this.langId = langId;
    this.key = key;
    this.value = value;
  }
}