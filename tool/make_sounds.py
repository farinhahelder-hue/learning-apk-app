# -*- coding: utf-8 -*-
"""Génère les sons de l'application.

Les sons livrés jusqu'ici étaient des placeholders, et la mesure le
montrait :

  tap.wav        1,75 s  joué à CHAQUE appui sur un bouton
  correct.wav    crête à 100 %  (saturé, le son le plus fort de l'app)
  countdown.wav  contenu à 5 100 Hz — strident
  musiques       boucles de 3,7 à 5,3 s répétées sans fin

Un clic d'interface doit durer quelques dizaines de millisecondes, pas
presque deux secondes. Une boucle de quatre secondes qui tourne pendant
un quart d'heure devient insupportable pour n'importe qui.

Principes de synthèse retenus, pour une enfant qui peut être sensible
au son :

- **Des sinusoïdes**, pas de signaux carrés : aucune harmonique dure.
- **Une attaque douce** (8 ms) : une attaque instantanée fait un clic.
- **Crête à 55 % maximum** : plus aucune saturation.
- **Fondamentales entre 300 et 1 100 Hz** : on évite la zone 2–5 kHz,
  celle où l'oreille est la plus vite agressée.
- **Gamme pentatonique** : deux notes prises au hasard dedans sonnent
  juste ensemble, donc aucun enchaînement ne peut être dissonant.

Usage :  python tool/make_sounds.py
"""
import array
import math
import os
import struct
import wave

SR = 22050          # effets
SR_MUSIC = 16000    # musiques : contenu grave, on peut échantillonner moins
OUT = 'assets/sounds'

# Gamme pentatonique de do majeur — do ré mi sol la.
NOTE = {
    'C4': 261.63, 'D4': 293.66, 'E4': 329.63, 'G4': 392.00, 'A4': 440.00,
    'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'G5': 783.99, 'A5': 880.00,
    'C6': 1046.50, 'D6': 1174.66, 'E6': 1318.51,
}


def env(i, n, attack=0.008, sr=SR, decay=4.0):
    """Enveloppe : attaque en cosinus, extinction exponentielle.

    L'attaque évite le clic de début ; l'extinction exponentielle imite
    la façon dont un son réel s'éteint, au lieu d'un arrêt net.
    """
    a = int(attack * sr)
    if i < a:
        return 0.5 - 0.5 * math.cos(math.pi * i / float(a))
    t = (i - a) / float(max(1, n - a))
    return math.exp(-decay * t)


def tone(freq, dur, amp=0.4, sr=SR, decay=4.0, attack=0.008, harm=(1.0, 0.22, 0.08)):
    """Une note : fondamentale plus deux harmoniques discrètes."""
    n = int(dur * sr)
    out = [0.0] * n
    for i in range(n):
        e = env(i, n, attack, sr, decay)
        t = i / float(sr)
        s = 0.0
        for k, h in enumerate(harm, start=1):
            if h:
                s += h * math.sin(2 * math.pi * freq * k * t)
        out[i] = s * e * amp
    return out


def mix(*layers):
    """Superpose des couches de longueurs différentes."""
    n = max(len(l) for l in layers)
    out = [0.0] * n
    for l in layers:
        for i, v in enumerate(l):
            out[i] += v
    return out


def seq(notes, sr=SR):
    """Enchaîne des notes : (fréquence, durée, amplitude, décalage)."""
    total = int(max(off + dur for _, dur, _, off in notes) * sr) + 1
    out = [0.0] * total
    for freq, dur, amp, off in notes:
        part = tone(freq, dur, amp, sr)
        start = int(off * sr)
        for i, v in enumerate(part):
            if start + i < total:
                out[start + i] += v
    return out


def normalize(buf, peak=0.55):
    """Ramène la crête au niveau voulu — jamais de saturation."""
    m = max(abs(v) for v in buf) if buf else 0
    if m == 0:
        return buf
    g = peak / m
    return [v * g for v in buf]


def write(name, buf, sr=SR, peak=0.55):
    buf = normalize(buf, peak)
    # Fondu de sortie : 5 ms, pour qu'aucun fichier ne finisse sur un clic.
    f = int(0.005 * sr)
    for i in range(min(f, len(buf))):
        buf[len(buf) - 1 - i] *= i / float(f)
    a = array.array('h', [int(max(-1.0, min(1.0, v)) * 32767) for v in buf])
    path = os.path.join(OUT, name)
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    w = wave.open(path, 'wb')
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sr)
    w.writeframes(a.tobytes())
    w.close()
    print('  %-32s %5.2fs  %6d octets' % (name, len(buf) / float(sr),
                                          os.path.getsize(path)))


# ══════════════════════════════════════════════════════════════
print('Effets :')

# Le clic. Court, sourd, discret — il se déclenche des centaines de fois.
write('tap.wav', tone(NOTE['A4'], 0.045, decay=9.0, attack=0.003,
                      harm=(1.0, 0.12, 0.0)), peak=0.30)

# Bonne réponse : deux notes qui montent, chaleureuses.
write('correct.wav', seq([
    (NOTE['E5'], 0.16, 0.5, 0.00),
    (NOTE['A5'], 0.26, 0.5, 0.09),
]), peak=0.50)

# Réponse à revoir. L'application ne punit jamais : ce son ne doit pas
# sonner comme une sanction. Deux notes graves, proches, très douces —
# une remarque, pas un buzzer.
write('wrong.wav', seq([
    (NOTE['D4'], 0.18, 0.40, 0.00),
    (NOTE['C4'], 0.26, 0.34, 0.10),
]), peak=0.34)

# Série de bonnes réponses.
write('combo.wav', seq([
    (NOTE['C5'], 0.13, 0.42, 0.00),
    (NOTE['E5'], 0.13, 0.42, 0.08),
    (NOTE['G5'], 0.28, 0.46, 0.16),
]), peak=0.48)

write('star.wav', seq([
    (NOTE['G5'], 0.12, 0.42, 0.00),
    (NOTE['C6'], 0.30, 0.44, 0.07),
]), peak=0.46)

write('level_up.wav', seq([
    (NOTE['C5'], 0.14, 0.40, 0.00),
    (NOTE['E5'], 0.14, 0.40, 0.10),
    (NOTE['G5'], 0.14, 0.42, 0.20),
    (NOTE['C6'], 0.38, 0.46, 0.30),
]), peak=0.50)

write('unlock.wav', seq([
    (NOTE['A4'], 0.14, 0.38, 0.00),
    (NOTE['E5'], 0.14, 0.40, 0.09),
    (NOTE['A5'], 0.34, 0.42, 0.18),
]), peak=0.48)

write('celebrate.wav', seq([
    (NOTE['C5'], 0.13, 0.38, 0.00),
    (NOTE['E5'], 0.13, 0.38, 0.09),
    (NOTE['G5'], 0.13, 0.40, 0.18),
    (NOTE['A5'], 0.13, 0.40, 0.27),
    (NOTE['C6'], 0.42, 0.44, 0.36),
]), peak=0.50)

write('perfect.wav', seq([
    (NOTE['C5'], 0.12, 0.36, 0.00),
    (NOTE['E5'], 0.12, 0.36, 0.08),
    (NOTE['G5'], 0.12, 0.38, 0.16),
    (NOTE['C6'], 0.12, 0.40, 0.24),
    (NOTE['E6'], 0.50, 0.42, 0.32),
    # Une quinte tenue en dessous : ça donne de l'ampleur sans monter
    # dans les aigus.
    (NOTE['G5'], 0.55, 0.20, 0.32),
]), peak=0.52)

# Décompte : l'ancien tombait à 5 100 Hz, strident. Un tic grave suffit
# à marquer le temps qui passe.
write('countdown.wav', tone(NOTE['E4'], 0.075, decay=8.0, attack=0.004,
                            harm=(1.0, 0.15, 0.0)), peak=0.34)

# Salut de mascotte : trois notes qui montent, brèves et amicales.
write('mascot_hello_bubulle.wav', seq([
    (NOTE['G4'], 0.10, 0.36, 0.00),
    (NOTE['C5'], 0.10, 0.38, 0.07),
    (NOTE['E5'], 0.22, 0.40, 0.14),
]), peak=0.44)

write('mascot_hello_floflo.wav', seq([
    (NOTE['E5'], 0.10, 0.36, 0.00),
    (NOTE['C5'], 0.10, 0.36, 0.07),
    (NOTE['G4'], 0.24, 0.38, 0.14),
]), peak=0.44)


# ══════════════════════════════════════════════════════════════
# Musiques de fond
#
# Les anciennes duraient 3,7 à 5,3 s et tournaient en boucle sans fin.
# On génère ici 32 s : quatre accords de huit temps, arpégés lentement,
# avec une nappe grave en dessous. La boucle reste une boucle, mais elle
# ne se signale plus toutes les quatre secondes.
print()
print('Musiques :')


def pad(freq, dur, amp, sr):
    """Nappe : une note tenue, sans attaque marquée."""
    n = int(dur * sr)
    out = [0.0] * n
    a = int(0.35 * sr)
    r = int(0.5 * sr)
    for i in range(n):
        if i < a:
            e = 0.5 - 0.5 * math.cos(math.pi * i / float(a))
        elif i > n - r:
            e = (n - i) / float(r)
        else:
            e = 1.0
        t = i / float(sr)
        out[i] = (math.sin(2 * math.pi * freq * t)
                  + 0.18 * math.sin(2 * math.pi * freq * 2 * t)) * e * amp
    return out


def make_music(chords, beat, arp_amp=0.30, pad_amp=0.16):
    """Quatre accords arpégés, plus une nappe tenue en dessous."""
    sr = SR_MUSIC
    bars = len(chords)
    total = int(bars * 8 * beat * sr) + sr
    out = [0.0] * total

    for b, chord in enumerate(chords):
        bar0 = b * 8 * beat
        # Nappe : la fondamentale une octave plus bas, tenue.
        low = pad(chord[0] / 2.0, 8 * beat, pad_amp, sr)
        s = int(bar0 * sr)
        for i, v in enumerate(low):
            if s + i < total:
                out[s + i] += v
        # Arpège : on parcourt l'accord, aller-retour.
        order = list(range(len(chord))) + list(range(len(chord) - 2, 0, -1))
        for step in range(8):
            f = chord[order[step % len(order)]]
            note = tone(f, beat * 1.8, arp_amp, sr, decay=3.0, attack=0.02,
                        harm=(1.0, 0.16, 0.05))
            s = int((bar0 + step * beat) * sr)
            for i, v in enumerate(note):
                if s + i < total:
                    out[s + i] += v
    return out, sr


N = NOTE
# Accueil — do majeur, paisible.
m, sr = make_music([
    [N['C4'], N['E4'], N['G4'], N['C5']],
    [N['A4'], N['C5'], N['E5'], N['A5']],
    [N['D4'], N['G4'], N['A4'], N['D5']],
    [N['G4'], N['C5'], N['D5'], N['G5']],
], beat=1.0)
write('music/music_home.wav', m, sr=sr, peak=0.34)

# Maths — un peu plus allant, sans excès.
m, sr = make_music([
    [N['G4'], N['C5'], N['D5'], N['G5']],
    [N['E4'], N['G4'], N['C5'], N['E5']],
    [N['A4'], N['D5'], N['E5'], N['A5']],
    [N['C5'], N['E5'], N['G5'], N['C6']],
], beat=0.85)
write('music/music_math.wav', m, sr=sr, peak=0.34)

# Français — plus lent, plus mélodique.
m, sr = make_music([
    [N['D4'], N['G4'], N['A4'], N['D5']],
    [N['C4'], N['E4'], N['G4'], N['C5']],
    [N['E4'], N['A4'], N['C5'], N['E5']],
    [N['G4'], N['C5'], N['E5'], N['G5']],
], beat=1.15)
write('music/music_french.wav', m, sr=sr, peak=0.32)

# Sciences — curieuse, intervalles plus ouverts.
m, sr = make_music([
    [N['A4'], N['C5'], N['E5'], N['A5']],
    [N['G4'], N['D5'], N['G5'], N['D6']],
    [N['C5'], N['G5'], N['C6'], N['E6']],
    [N['E4'], N['A4'], N['D5'], N['G5']],
], beat=1.0)
write('music/music_science.wav', m, sr=sr, peak=0.33)

print()
print('Terminé.')
