import { ethers } from "ethers";
interface PricePoint { timestamp: number; price: number; source: string; }
export class PriceHistory {
  private history: PricePoint[] = [];
  record(price: number, source: string) {
    this.history.push({ timestamp: Date.now(), price, source });
    if (this.history.length > 2880) this.history.shift();
  }
  getVolatility(hours = 24): number {
    const cutoff = Date.now() - hours * 3600000;
    const recent = this.history.filter(p => p.timestamp > cutoff).map(p => p.price);
    if (recent.length < 2) return 0;
    const mean = recent.reduce((a, b) => a + b) / recent.length;
    const variance = recent.reduce((acc, p) => acc + Math.pow(p - mean, 2), 0) / recent.length;
    return Math.sqrt(variance) / mean * 100;
  }
}
