/* @pjs font="lucon.ttf"; */

boolean keys[] = new boolean[128];
boolean encKeys[] = new boolean[128];

char keyboard[] = {'Q', 'W', 'E', 'R', 'T', 'Z', 'U', 'I', 'O', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'P', 'Y', 'X', 'C', 'V', 'B', 'N', 'M', 'L'};

//                  A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q    R    S    T    U    V    W    X    Y    Z
int rotor_I[]   = {'E', 'K', 'M', 'F', 'L', 'G', 'D', 'Q', 'V', 'Z', 'N', 'T', 'O', 'W', 'Y', 'H', 'X', 'U', 'S', 'P', 'A', 'I', 'B', 'R', 'C', 'J', 'R'};
int rotor_II[]  = {'A', 'J', 'D', 'K', 'S', 'I', 'R', 'U', 'X', 'B', 'L', 'H', 'W', 'T', 'M', 'C', 'Q', 'G', 'Z', 'N', 'P', 'Y', 'F', 'V', 'O', 'E', 'F'};
int rotor_III[] = {'B', 'D', 'F', 'H', 'J', 'L', 'C', 'P', 'R', 'T', 'X', 'V', 'Z', 'N', 'Y', 'E', 'I', 'W', 'G', 'A', 'K', 'M', 'U', 'S', 'Q', 'O', 'W'};

int refl_B[]    = {'Y', 'R', 'U', 'H', 'Q', 'S', 'L', 'D', 'P', 'X', 'N', 'G', 'O', 'K', 'M', 'I', 'E', 'B', 'F', 'Z', 'C', 'W', 'V', 'J', 'A', 'T'};
int refl_C[]    = {'F', 'V', 'P', 'J', 'I', 'A', 'O', 'Y', 'E', 'D', 'R', 'Z', 'X', 'W', 'G', 'C', 'T', 'K', 'U', 'Q', 'S', 'B', 'N', 'M', 'H', 'L'};

int plugboard[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};

int rotors[] = {0, 0, 0};
int rotorConfig[][] = {rotor_I, rotor_II, rotor_III};
String rotorNames[] = {"I", "II", "III"};
int reflector[] = refl_B;
String relfName = "B";

boolean pressed;

int command = 0;
int swapChar;

//String decode = "";

String plaintext = "", ciphertext = "";

long cTimer;
long rTimer;
int cKey = 0;
boolean updated = false;

void resetCipher() {
  plaintext = "";
  ciphertext = "";
}

void setup() {
  size(1920 * 0.6, 1080 * 0.68, P2D);
  rectMode(CORNERS);
  textAlign(CENTER);
  textFont(createFont("lucon.ttf", 48));
  noSmooth();
  frameRate(60);
  for (int i = 0; i < 26; i++) {
    rotor_I[i] -= int('A');
    rotor_II[i] -= int('A');
    rotor_III[i] -= int('A');
    refl_B[i] -= int('A');
    refl_C[i] -= int('A');
    plugboard[i] -= int('A');
  }
}

void draw() {
  if (_reset == 1) {
    _reset = 0;
    resetCipher();
  }
  if (_plaintext.length() > 0) {
    plaintext = _plaintext;
    _plaintext = "";
  }
  _ciphertext = ciphertext;
  
  if (plaintext.length() > 0 && millis() - cTimer >= 100) {
    cKey = int(plaintext.toCharArray()[0]);
    if (cKey < int('A') || cKey > int('Z')) {
      ciphertext += plaintext.toCharArray()[0];
      return;
    }
    keys[cKey] = true;
    plaintext = plaintext.substring(1);
    updated = true;
    cTimer = millis();
    rTimer = millis();
  }
  if (millis() - rTimer >= 50 && (plaintext.length() > 0 || cKey != 0)) {
    keys[cKey] = false;
    if (plaintext.length() == 0 && cKey != 0) {
      cKey = 0;
    }
  }
  int p = -1;
  for (int i = 0; i < 128; i++) {
    if (keys[i] && i >= int('A') && i <= int('Z')) {
      if (!pressed) {
        rotors[2] = (rotors[2] + 1) % 26;
        if (rotors[2] == int(rotorConfig[2][26]) - int('A')) {
          rotors[1] = (rotors[1] + 1) % 26;
          if (rotors[1] == int(rotorConfig[1][26]) - int('A')) {
            rotors[0] = (rotors[0] + 1) % 26;
          }
        }
        pressed = true;
      }
      p = i;
    }
  }
  if (p == -1) {
    pressed = false;
    for (int i = int('A'); i <= int('Z'); i++) {
      encKeys[i] = false;
    }
  } else {
    //decode = "";
    int k = getPlugboard(getRotors(getPlugboard(p - int('A')))) + int('A');
    if (cKey != 0 && updated) {
      updated = false;
      ciphertext += toChar(k);
    }
    encKeys[k] = true;
  }
  background(255);
  fill(0, 30, 10);
  noStroke();
  rect(10, 10, width / 2 - 5, height - 10, 20);
  rect(width / 2 + 5, 10, width - 10, height - 10, 20);
  // keyboard
  textSize(28);
  for (int i = 0; i < 9; i++) {
    fill(255);
    int s = 0;
    if (keys[int(keyboard[i])]) {
      fill(100);
      s = 5;
    }
    ellipse(width / 4 + (i - 4) * 50, height / 2 + 100 + s, 45, 45);
    fill(0);
    text(keyboard[i], width / 4 + (i - 4) * 50, height / 2 + 109 + s);
  }
  for (int i = 0; i < 8; i++) {
    fill(255);
    int s = 0;
    if (keys[int(keyboard[i + 9])]) {
      fill(100);
      s = 5;
    }
    ellipse(width / 4 + (i - 3.5) * 50, height / 2 + 150 + s, 45, 45);
    fill(0);
    text(keyboard[i + 9], width / 4 + (i - 3.5) * 50, height / 2 + 159 + s);
  }
  for (int i = 0; i < 9; i++) {
    fill(255);
    int s = 0;
    if (keys[int(keyboard[i + 17])]) {
      fill(100);
      s = 5;
    }
    ellipse(width / 4 + (i - 4) * 50, height / 2 + 200 + s, 45, 45);
    fill(0);
    text(keyboard[i + 17], width / 4 + (i - 4) * 50, height / 2 + 209 + s);
  }
  // lamps
  for (int i = 0; i < 9; i++) {
    fill(50);
    int s = 45;
    if (encKeys[int(keyboard[i])]) {
      fill(255, 255, 0);
      s = 50;
    }
    ellipse(width / 4 + (i - 4) * 50, height / 2 - 100, s, s);
    fill(0);
    text(keyboard[i], width / 4 + (i - 4) * 50, height / 2 - 91);
  }
  for (int i = 0; i < 8; i++) {
    fill(50);
    int s = 45;
    if (encKeys[int(keyboard[i + 9])]) {
      fill(255, 255, 0);
      s = 50;
    }
    ellipse(width / 4 + (i - 3.5) * 50, height / 2 - 50, s, s);
    fill(0);
    text(keyboard[i + 9], width / 4 + (i - 3.5) * 50, height / 2 - 41);
  }
  for (int i = 0; i < 9; i++) {
    fill(50);
    int s = 45;
    if (encKeys[int(keyboard[i + 17])]) {
      fill(255, 255, 0);
      s = 50;
    }
    ellipse(width / 4 + (i - 4) * 50, height / 2, s, s);
    fill(0);
    text(keyboard[i + 17], width / 4 + (i - 4) * 50, height / 2 + 9);
  }
  // rotors
  rectMode(CENTER);
  for (int i = 0; i < 3; i++) {
    fill(255);
    rect(width / 4 + (i - 1) * 140, height / 2 - 240, 50, 70, 10);
    rect(width / 4 + (i - 1) * 140, height / 2 - 300, 50, 30, 10);
    fill(0);
    textSize(48);
    text(char(rotors[i] + int('A')), width / 4 + (i - 1) * 140, height / 2 - 240 + 17);
    textSize(24);
    text(rotorNames[i], width / 4 + (i - 1) * 140, height / 2 - 300 + 8);
  }
  fill(255);
  rect(width / 4 - 210, height / 2 - 240, 40, 50, 10);
  fill(0);
  textSize(28);
  text(relfName, width / 4 - 210, height / 2 - 240 + 10);
  // plugboard
  textSize(24);
  for (int i = 0; i < 26; i++) {
    stroke(127);
    int c = getPlugboard(i);
    strokeWeight(3);
    line(width * (3.0 / 4.0) - 210 - 3, height / 2 + (i - 12.5) * 25, width * (3.0 / 4.0) + 210 - 3, height / 2 + (c - 12.5) * 25);
    strokeWeight(1);
  }
  for (int i = 0; i < 26; i++) {
    fill(255);
    noStroke();
    rect(width * (3.0 / 4.0) - 210 - 3, height / 2 + (i - 12.5) * 25, 20, 20, 5);
    rect(width * (3.0 / 4.0) + 210 - 3, height / 2 + (i - 12.5) * 25, 20, 20, 5);
    fill(0);
    text(toChar(i + int('A')), width * (3.0 / 4.0) - 210 - 3, height / 2 + (i - 12.5) * 25 + 7);
    text(toChar(i + int('A')), width * (3.0 / 4.0) + 210 - 3, height / 2 + (i - 12.5) * 25 + 7);
  }
  rectMode(CORNERS);
}

String toChar(int k) {
  switch (k) {
  case 65:
    return "A";
  case 66:
    return "B";
  case 67:
    return "C";
  case 68:
    return "D";
  case 69:
    return "E";
  case 70:
    return "F";
  case 71:
    return "G";
  case 72:
    return "H";
  case 73:
    return "I";
  case 74:
    return "J";
  case 75:
    return "K";
  case 76:
    return "L";
  case 77:
    return "M";
  case 78:
    return "N";
  case 79:
    return "O";
  case 80:
    return "P";
  case 81:
    return "Q";
  case 82:
    return "R";
  case 83:
    return "S";
  case 84:
    return "T";
  case 85:
    return "U";
  case 86:
    return "V";
  case 87:
    return "W";
  case 88:
    return "X";
  case 89:
    return "Y";
  case 90:
    return "Z";
  }
  return "ERR";
}

int inRange(int k) {
  while (k > 25) {
    k -= 26;
  }
  while (k < 0) {
    k += 26;
  }
  return k;
}

int getRotorRev(int s, int k) {
  k = inRange(k + rotors[s]);
  for (int i = 0; i < 26; i++) {
    if (rotorConfig[s][i] == k) {
      return inRange(i - rotors[s]);
    }
  }
  return -1;
}

int getRotor(int s, int k) {
  k = inRange(k + rotors[s]);
  return inRange(rotorConfig[s][k] - rotors[s]);
}

int getReflector(int k) {
  return reflector[k];
}

int getRotors(int k) {
  return getRotorRev(2, getRotorRev(1, getRotorRev(0, getReflector(getRotor(0, getRotor(1, getRotor(2, k)))))));
}

int getPlugboard(int k) {
  return plugboard[k];
}

void keyPressed() {
  if (plaintext.length() > 0) {
    return;
  }
  if (keyCode == CONTROL) {
    command = 2;
  } else if (command > 0) {
    if (keyCode >= int('A') && keyCode <= int('Z')) {
      if (command == 2) {
        swapChar = keyCode - int('A');
      } else {
        if (plugboard[swapChar] == keyCode - int('A') || (swapChar == plugboard[swapChar] && keyCode - int('A') == plugboard[keyCode - int('A')])) {
          int tmp = plugboard[swapChar];
          plugboard[swapChar] = plugboard[keyCode - int('A')];
          plugboard[keyCode - int('A')] = tmp;
        }
      }
      command--;
    } else if (key == ' ') {
      rotors[0] = 0;
      rotors[1] = 0;
      rotors[2] = 0;
      command = 0;
    } else if (keyCode >= int('1') && keyCode <= int('3')) {
      if (command == 2) {
        swapChar = keyCode - int('1');
      } else {
        if (keyCode == int('1')) {
          rotorConfig[swapChar] = rotor_I;
          rotorNames[swapChar] = "I";
        } else if (keyCode == int('2')) {
          rotorConfig[swapChar] = rotor_II;
          rotorNames[swapChar] = "II";
        } else if (keyCode == int('3')) {
          rotorConfig[swapChar] = rotor_III;
          rotorNames[swapChar] = "III";
        }
      }
      command--;
    }
    return;
  }
  if (keyCode > 127) {
    return;
  }
  keys[keyCode] = true;
}

void keyReleased() {
  if (plaintext.length() > 0) {
    return;
  }
  if (keyCode > 127) {
    return;
  }
  keys[keyCode] = false;
}
