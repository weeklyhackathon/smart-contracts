import fs from "node:fs";

export const env = (variable: string, defaultValue?: string): string => {
    if (process.env[variable]) return process.env[variable] as string;
    else if (defaultValue) return defaultValue;
    else throw new Error(`Environment variable: "${variable}" not set`);
};

export const envAsAddress = (variable: string, defaultValue?: `0x${string}`): `0x${string}` => {
    if (process.env[variable]) {
        const x = process.env[variable] as string;
        // TODO: checksum.
        if (/0x[0-9a-f]{40}/i.test(x)) return x as `0x${string}`;
        else throw new Error(`Environment variable: ${variable} is not an address`);
    }
    else if (defaultValue) return defaultValue;
    else throw new Error(`Environment variable: "${variable}" not set`);
};

export const envAsNumber = (variable: string, defaultValue?: number): number => {
    const key = process.env[variable];
    if (!key) {
        if (defaultValue === undefined) throw new Error(`Environment variable: "${variable}" not set`);
        else return defaultValue;
    }

    if (/^\d+$/.test(key)) return parseInt(key);
    else throw new Error(`Environment variable: ${key} is not a number`);
};

export const envAsBigInt = (variable: string, defaultValue?: bigint): bigint => {
    const key = process.env[variable];
    if (!key) {
        if (defaultValue === undefined) throw new Error(`Environment variable: "${variable}" not set`);
        else return defaultValue;
    }

    if (/^\d+$/.test(key)) return BigInt(key);
    else throw new Error(`Environment variable: ${key} is not a number`);
};

export class DataRecorder {
    public readonly filename;
    private data: Record<string, string> = {};
    
    constructor(suffix: string) {
        if (!process.env.APP_ENV) throw new Error("Environment variable APP_ENV must be set");
        this.filename = `./.env.${process.env.APP_ENV}.${suffix}`;
    }

    set = (k: string, v: string | number | bigint | boolean) => {
        if (typeof v === "number" || typeof v === "bigint" || typeof v === "boolean") v = v.toString();
        this.data[k] = v;
        this.write();
    };

    write = () => {
        const content = Object.entries(this.data).map(([k, v]) => `${k}="${v}"`).join("\n") + "\n";
        fs.writeFileSync(this.filename, content);
    };
}

