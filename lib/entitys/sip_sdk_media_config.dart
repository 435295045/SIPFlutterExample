class SIPSDKMediaConfig {
  final int audioClockRate;
  final double micGain;
  final double speakerGain;
  final bool nsEnable;
  final bool agcEnable;
  final bool aecEnable;
  final int aecEliminationTime;
  final bool notEnableEncode;
  final bool notEnableDecode;
  final int decodeMaxWidth;
  final int decodeMaxHeight;
  final bool combinSpsPpsIdr;
  final String? profileLevelId;
  final String? packetizationMode;

  SIPSDKMediaConfig({
    this.audioClockRate = 16000,
    this.micGain = 1.0,
    this.speakerGain = 1.0,
    this.nsEnable = true,
    this.agcEnable = true,
    this.aecEnable = true,
    this.aecEliminationTime = 30,
    this.notEnableEncode = false,
    this.notEnableDecode = false,
    this.decodeMaxWidth = 1920,
    this.decodeMaxHeight = 1080,
    this.combinSpsPpsIdr = false,
    this.profileLevelId,
    this.packetizationMode,
  });

  Map<String, Object?> toJson() => {
    'audioClockRate': audioClockRate,
    'micGain': micGain,
    'speakerGain': speakerGain,
    'nsEnable': nsEnable,
    'agcEnable': agcEnable,
    'aecEnable': aecEnable,
    'aecEliminationTime': aecEliminationTime,
    'notEnableEncode': notEnableEncode,
    'notEnableDecode': notEnableDecode,
    'decodeMaxWidth': decodeMaxWidth,
    'decodeMaxHeight': decodeMaxHeight,
    'combinSpsPpsIdr': combinSpsPpsIdr,
    'profileLevelId': profileLevelId,
    'packetizationMode': packetizationMode,
  };

  factory SIPSDKMediaConfig.fromJson(Map<String, dynamic> json) {
    return SIPSDKMediaConfig(
      audioClockRate: json['audioClockRate'] is int ? json['audioClockRate'] as int : 16000,
      micGain: json['micGain'] is num ? (json['micGain'] as num).toDouble() : 1.0,
      speakerGain: json['speakerGain'] is num ? (json['speakerGain'] as num).toDouble() : 1.0,
      nsEnable: json['nsEnable'] is bool ? json['nsEnable'] as bool : true,
      agcEnable: json['agcEnable'] is bool ? json['agcEnable'] as bool : true,
      aecEnable: json['aecEnable'] is bool ? json['aecEnable'] as bool : true,
      aecEliminationTime: json['aecEliminationTime'] is int ? json['aecEliminationTime'] as int : 30,
      notEnableEncode: json['notEnableEncode'] is bool ? json['notEnableEncode'] as bool : false,
      notEnableDecode: json['notEnableDecode'] is bool ? json['notEnableDecode'] as bool : false,
      decodeMaxWidth: json['decodeMaxWidth'] is int ? json['decodeMaxWidth'] as int : 1920,
      decodeMaxHeight: json['decodeMaxHeight'] is int ? json['decodeMaxHeight'] as int : 1080,
      combinSpsPpsIdr: json['combinSpsPpsIdr'] is bool ? json['combinSpsPpsIdr'] as bool : false,
      profileLevelId: json['profileLevelId'] as String?,
      packetizationMode: json['packetizationMode'] as String?,
    );
  }
}
