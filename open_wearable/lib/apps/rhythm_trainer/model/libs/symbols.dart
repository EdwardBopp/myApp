import 'package:flutter/material.dart';
import 'package:simple_sheet_music/simple_sheet_music.dart';



class Symbols {

  static const clef = Clef.treble();

  static const blackQuarterNote = Note(Pitch.g4, noteDuration: NoteDuration.quarter, color: Colors.black);
  static const blackHalfNote = Note(Pitch.g4, noteDuration: NoteDuration.half, color: Colors.black);
  static const blackWholeNote = Note(Pitch.g4, noteDuration: NoteDuration.whole, color: Colors.black);
  static const blackEighthNote = Note(Pitch.g4, noteDuration: NoteDuration.eighth, color: Colors.black);

  static const redWholeNote = Note(Pitch.g4, noteDuration: NoteDuration.whole, color: Colors.red);
  static const redHalfNote = Note(Pitch.g4, noteDuration: NoteDuration.half, color: Colors.red);
  static const redQuarterNote = Note(Pitch.g4, noteDuration: NoteDuration.quarter, color: Colors.red);
  static const redEighthNote = Note(Pitch.g4, noteDuration: NoteDuration.eighth, color: Colors.red);

  static const greenWholeNote = Note(Pitch.g4, noteDuration: NoteDuration.whole, color: Colors.green);
  static const greenHalfNote = Note(Pitch.g4, noteDuration: NoteDuration.half, color: Colors.green);
  static const greenQuarterNote = Note(Pitch.g4, noteDuration: NoteDuration.quarter, color: Colors.green);
  static const greenEighthNote = Note(Pitch.g4, noteDuration: NoteDuration.eighth, color: Colors.green);

  Map<NoteDuration, Map<Color, Note>> get coloredNotes => {
    NoteDuration.whole: {
      Colors.black: blackWholeNote,
      Colors.red: redWholeNote,
      Colors.green: greenWholeNote,
    },
    NoteDuration.half: {
      Colors.black: blackHalfNote,
      Colors.red: redHalfNote,
      Colors.green: greenHalfNote,
    },
    NoteDuration.quarter: {
      Colors.black: blackQuarterNote,
      Colors.red: redQuarterNote,
      Colors.green: greenQuarterNote,
    },
    NoteDuration.eighth: {
      Colors.black: blackEighthNote,
      Colors.red: redEighthNote,
      Colors.green: greenEighthNote,
    },
  };

  static const restWhole = Rest(RestType.whole);
  static const restHalf = Rest(RestType.half);
  static const restQuarter = Rest(RestType.quarter);
  static const restEighth = Rest(RestType.eighth);


  static Note getColoredNote(Set<Note> notes, Color color) {

    for(Note note in notes) {
      if(note.color == color) {
        return note;
      }
    }

    throw Exception("No note found with the specified color"); 
  }
}
