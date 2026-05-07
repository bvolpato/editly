import { execa } from 'execa';

// todo use jest
await execa('node', [
  'cli.js',
  "title:'My video'",
  "title:'THE END'",
  '--fast',
  '--duration',
  '1',
  '--transition-name',
  'dummy',
], { stdout: process.stdout, stderr: process.stderr });
