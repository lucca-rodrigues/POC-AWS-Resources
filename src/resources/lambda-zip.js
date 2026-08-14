// ===========================================================================
// EMPACOTAMENTO
// ---------------------------------------------------------------------------
// Empacota o código da Lambda (diretório) num ZIP em memória (buffer).
// É o que o deploy faz: empacota o código da Lambda num ZIP.
// ===========================================================================

import { ZipArchive } from "archiver";

export async function buildZipFromDir(dir) {
	return new Promise((resolve, reject) => {
		const archive = new ZipArchive({ zlib: { level: 9 } });
		const chunks = [];

		archive.on("data", (chunk) => chunks.push(chunk));
		archive.on("error", reject);
		archive.on("end", () => resolve(Buffer.concat(chunks)));

		archive.directory(dir, false);
		archive.finalize();
	});
}
