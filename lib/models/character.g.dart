// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually maintained - updated to include job fields (71-73).

part of 'character.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterAdapter extends TypeAdapter<Character> {
  @override
  final int typeId = 0;

  @override
  Character read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Character(
      name: fields[0] as String,
      age: fields[1] as int,
      city: fields[2] as String,
      bankBalance: fields[3] as double,
      jobTitle: fields[4] as String,
      happiness: fields[5] as int,
      health: fields[6] as int,
      smarts: fields[7] as int,
      social: fields[8] as int,
      karma: fields[9] as int,
      isDead: fields[10] as bool,
      personality: fields[11] as String,
      educationLevel: fields[12] as String,
      degree: fields[13] as String,
      totalEarned: fields[14] as double,
      gender: fields[16] as String,
      annualIncome: fields[17] as double,
      annualExpenses: fields[18] as double,
      careerGroup: fields[19] as String,
      careerStep: fields[20] as int,
      yearsInRole: fields[21] as int,
      cibilScore: fields[24] as int,
      bankName: fields[25] as String,
      accountType: fields[26] as String,
      savingsBalance: fields[27] as double,
      loanAmount: fields[28] as double,
      hasCreditCard: fields[29] as bool,
      loanType: fields[30] as String,
      creditUsed: fields[31] as double,
      lastActivityAge: fields[32] as int,
      momentumStreak: fields[38] as int,
      version: fields[39] as int,
      lastSavedAt: fields[40] as int,
      activeDominantTrait: fields[42] as String,
      lastTraitShiftAge: fields[43] as int,
      lastAutoDecisionAge: fields[44] as int,
      momentumState: fields[45] as String,
      identityPhase: fields[46] as String,
      phaseYearsStored: fields[47] as int,
      legacyPoints: fields[50] as int,
      universityType: fields[52] as String,
      isDroppedYear: fields[54] as bool,
      stateVersion: fields[55] as int,
      parentWealth: fields[56] as String,
      parentEdu: fields[57] as String,
      stressLevel: fields[58] as int,
      prepLevel: fields[59] as int,
      schoolType: fields[60] as String,
      specialization: fields[61] as String,
      studyConsistency: fields[62] as int,
      discipline: fields[63] as int,
      dropYearsCount: fields[64] as int,
      lastDemotionAge: fields[65] as int,
      hasCareerWarning: fields[66] as bool,
      freelanceEffort: fields[67] as int,
      achievements: (fields[15] as List?)?.cast<String>() ?? <String>[],
      ownedAssets: (fields[22] as List?)?.cast<String>() ?? <String>[],
      relationships: (fields[23] as List?)?.cast<Relationship>() ?? <Relationship>[],
      stockPortfolio: (fields[33] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList() ?? <Map<dynamic, dynamic>>[],
      cryptoPortfolio: (fields[34] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList() ?? <Map<dynamic, dynamic>>[],
      bondPortfolio: (fields[35] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList() ?? <Map<dynamic, dynamic>>[],
      marketPrices: (fields[36] as Map?)?.cast<dynamic, dynamic>() ?? <dynamic, dynamic>{},
      eventChains: (fields[37] as Map?)?.cast<String, int>() ?? <String, int>{},
      personalityScores: (fields[41] as Map?)?.cast<String, int>() ?? <String, int>{},
      hiddenModifiers: (fields[48] as Map?)?.cast<String, double>() ?? <String, double>{},
      majorDecisions: (fields[49] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList() ?? <Map<String, dynamic>>[],
      tensionSignals: (fields[51] as List?)?.cast<String>() ?? <String>[],
      examResults: (fields[53] as Map?)?.cast<String, int>() ?? <String, int>{},
      unlockedActivityIds: (fields[68] as List?)?.cast<String>() ?? <String>[],
      unlockedCareerModuleIds: (fields[69] as List?)?.cast<String>() ?? <String>[],
      loans: (fields[70] as List?)?.cast<LoanModel>() ?? <LoanModel>[],
      jobPerformance: (fields[71] as num?)?.toDouble() ?? 50,
      yearsInJob: fields[72] as int? ?? 0,
      jobLevel: fields[73] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Character obj) {
    writer
      ..writeByte(74)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.bankBalance)
      ..writeByte(4)
      ..write(obj.jobTitle)
      ..writeByte(5)
      ..write(obj.happiness)
      ..writeByte(6)
      ..write(obj.health)
      ..writeByte(7)
      ..write(obj.smarts)
      ..writeByte(8)
      ..write(obj.social)
      ..writeByte(9)
      ..write(obj.karma)
      ..writeByte(10)
      ..write(obj.isDead)
      ..writeByte(11)
      ..write(obj.personality)
      ..writeByte(12)
      ..write(obj.educationLevel)
      ..writeByte(13)
      ..write(obj.degree)
      ..writeByte(14)
      ..write(obj.totalEarned)
      ..writeByte(15)
      ..write(obj.achievements)
      ..writeByte(16)
      ..write(obj.gender)
      ..writeByte(17)
      ..write(obj.annualIncome)
      ..writeByte(18)
      ..write(obj.annualExpenses)
      ..writeByte(19)
      ..write(obj.careerGroup)
      ..writeByte(20)
      ..write(obj.careerStep)
      ..writeByte(21)
      ..write(obj.yearsInRole)
      ..writeByte(22)
      ..write(obj.ownedAssets)
      ..writeByte(23)
      ..write(obj.relationships)
      ..writeByte(24)
      ..write(obj.cibilScore)
      ..writeByte(25)
      ..write(obj.bankName)
      ..writeByte(26)
      ..write(obj.accountType)
      ..writeByte(27)
      ..write(obj.savingsBalance)
      ..writeByte(28)
      ..write(obj.loanAmount)
      ..writeByte(29)
      ..write(obj.hasCreditCard)
      ..writeByte(30)
      ..write(obj.loanType)
      ..writeByte(31)
      ..write(obj.creditUsed)
      ..writeByte(32)
      ..write(obj.lastActivityAge)
      ..writeByte(33)
      ..write(obj.stockPortfolio)
      ..writeByte(34)
      ..write(obj.cryptoPortfolio)
      ..writeByte(35)
      ..write(obj.bondPortfolio)
      ..writeByte(36)
      ..write(obj.marketPrices)
      ..writeByte(37)
      ..write(obj.eventChains)
      ..writeByte(38)
      ..write(obj.momentumStreak)
      ..writeByte(39)
      ..write(obj.version)
      ..writeByte(40)
      ..write(obj.lastSavedAt)
      ..writeByte(41)
      ..write(obj.personalityScores)
      ..writeByte(42)
      ..write(obj.activeDominantTrait)
      ..writeByte(43)
      ..write(obj.lastTraitShiftAge)
      ..writeByte(44)
      ..write(obj.lastAutoDecisionAge)
      ..writeByte(45)
      ..write(obj.momentumState)
      ..writeByte(46)
      ..write(obj.identityPhase)
      ..writeByte(47)
      ..write(obj.phaseYearsStored)
      ..writeByte(48)
      ..write(obj.hiddenModifiers)
      ..writeByte(49)
      ..write(obj.majorDecisions)
      ..writeByte(50)
      ..write(obj.legacyPoints)
      ..writeByte(51)
      ..write(obj.tensionSignals)
      ..writeByte(52)
      ..write(obj.universityType)
      ..writeByte(53)
      ..write(obj.examResults)
      ..writeByte(54)
      ..write(obj.isDroppedYear)
      ..writeByte(55)
      ..write(obj.stateVersion)
      ..writeByte(56)
      ..write(obj.parentWealth)
      ..writeByte(57)
      ..write(obj.parentEdu)
      ..writeByte(58)
      ..write(obj.stressLevel)
      ..writeByte(59)
      ..write(obj.prepLevel)
      ..writeByte(60)
      ..write(obj.schoolType)
      ..writeByte(61)
      ..write(obj.specialization)
      ..writeByte(62)
      ..write(obj.studyConsistency)
      ..writeByte(63)
      ..write(obj.discipline)
      ..writeByte(64)
      ..write(obj.dropYearsCount)
      ..writeByte(65)
      ..write(obj.lastDemotionAge)
      ..writeByte(66)
      ..write(obj.hasCareerWarning)
      ..writeByte(67)
      ..write(obj.freelanceEffort)
      ..writeByte(68)
      ..write(obj.unlockedActivityIds)
      ..writeByte(69)
      ..write(obj.unlockedCareerModuleIds)
      ..writeByte(70)
      ..write(obj.loans)
      ..writeByte(71)
      ..write(obj.jobPerformance)
      ..writeByte(72)
      ..write(obj.yearsInJob)
      ..writeByte(73)
      ..write(obj.jobLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
