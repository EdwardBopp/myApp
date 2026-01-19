import 'package:open_wearable/apps/rhythm_trainer/model/libs/symbols.dart';
import 'package:open_wearable/apps/rhythm_trainer/model/musical_symbol.dart' as rt;
import 'package:simple_sheet_music/simple_sheet_music.dart';

class SymbolConverter {

  static MusicalSymbol convert(rt.MusicalSymbol symbol) {

    switch(symbol) {

        case rt.MusicalSymbol.wholeNote:
          return Symbols.blackWholeNote;
                 
        case rt.MusicalSymbol.halfNote:
          return Symbols.blackHalfNote;
          
        case rt.MusicalSymbol.quarterNote:
          return Symbols.blackQuarterNote;

        case rt.MusicalSymbol.eighthNote:
          return Symbols.blackEighthNote;

        case rt.MusicalSymbol.restWhole:
          return Symbols.restWhole;
         
        case rt.MusicalSymbol.restHalf:
          return Symbols.restHalf;
         
        case rt.MusicalSymbol.restQuarter:
          return Symbols.restQuarter;
          
        case rt.MusicalSymbol.restEighth:
          return Symbols.restEighth;
        
      }
  }
}
