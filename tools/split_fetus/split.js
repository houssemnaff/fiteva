// Run from this directory:
//   npm install
//   node split.js
//
// Input:  ../../assets/fetus_sheet.png   (6×7 grid, 40 fetus weeks, black bg)
// Output: ../../assets/fetus/week_1.png … week_40.png

const path = require('path');
const fs   = require('fs');

const ROOT       = path.resolve(__dirname, '..', '..');
const INPUT      = path.join(ROOT, 'assets', 'fetus_sheet.png');
const OUTPUT_DIR = path.join(ROOT, 'assets', 'fetus');

const COLS  = 6;
const ROWS  = 7;
const TOTAL = 40; // cells 41 and 42 are empty — skip them

async function main() {
  if (!fs.existsSync(INPUT)) {
    console.error(`❌  Not found: ${INPUT}`);
    console.error('    Place fetus_sheet.png in assets/ first.');
    process.exit(1);
  }

  let sharp;
  try {
    sharp = require('sharp');
  } catch {
    console.error('❌  sharp not installed. Run:  npm install');
    process.exit(1);
  }

  fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const meta = await sharp(INPUT).metadata();
  const { width, height } = meta;

  const cellW = Math.floor(width  / COLS);
  const cellH = Math.floor(height / ROWS);

  console.log(`Sheet: ${width}×${height}  →  grid: ${COLS}×${ROWS}  →  cell: ${cellW}×${cellH}`);

  for (let i = 0; i < TOTAL; i++) {
    const row  = Math.floor(i / COLS);
    const col  = i % COLS;
    const week = i + 1;
    const outFile = path.join(OUTPUT_DIR, `week_${week}.png`);

    await sharp(INPUT)
      .extract({ left: col * cellW, top: row * cellH, width: cellW, height: cellH })
      .png()
      .toFile(outFile);

    process.stdout.write(`  ✅  week_${week}.png\n`);
  }

  console.log(`\nDone! ${TOTAL} images saved to assets/fetus/`);
  console.log('Run "flutter pub get" then rebuild the app.');
}

main().catch(err => { console.error(err); process.exit(1); });
