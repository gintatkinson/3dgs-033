import 'package:app_flutter/domain/counter_gauge.dart';
import 'package:app_flutter/domain/date_time.dart';
import 'package:app_flutter/domain/oid.dart';
import 'package:app_flutter/domain/time_duration.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Generic validation function that evaluates constraints on a map of input values.
bool validateFields(Map<String, dynamic> input, List<FieldDescriptor> descriptors) {
  for (final fd in descriptors) {
    final value = input[fd.key];

    // If missing/empty, check required constraint. Otherwise skip validation if not required.
    if (value == null || (value is String && value.isEmpty)) {
      if (fd.required) {
        return false;
      }
      continue;
    }

    final strVal = value.toString();
    if (fd.type == 'int') {
      final parsed = int.tryParse(strVal);
      if (parsed == null) return false;
      if (fd.minValue != null && parsed < fd.minValue!) return false;
      if (fd.maxValue != null && parsed > fd.maxValue!) return false;
    } else if (fd.type == 'double' || fd.type == 'real') {
      final parsed = double.tryParse(strVal);
      if (parsed == null) return false;
      if (fd.minValue != null && parsed < fd.minValue!) return false;
      if (fd.maxValue != null && parsed > fd.maxValue!) return false;
    } else if (fd.type == 'string') {
      if (fd.pattern != null && fd.pattern!.isNotEmpty) {
        final regex = RegExp(fd.pattern!);
        if (!regex.hasMatch(strVal)) return false;
      }
    } else if (fd.type == 'enum') {
      if (fd.enumOptions != null && !fd.enumOptions!.contains(strVal)) {
        return false;
      }
    } else if (fd.type == 'oid') {
      try {
        OidValue.parse(strVal);
      } on OidValidationException {
        return false;
      }
    } else if (fd.type == 'oid128') {
      try {
        Oid128.parse(strVal);
      } on OidValidationException {
        return false;
      }
    } else if (fd.type == 'counter32') {
      final parsed = int.tryParse(strVal);
      if (parsed == null) return false;
      try {
        Counter32(parsed);
      } on CounterGaugeValidationException {
        return false;
      }
    } else if (fd.type == 'counter64') {
      final parsed = BigInt.tryParse(strVal);
      if (parsed == null) return false;
      try {
        Counter64(parsed);
      } on CounterGaugeValidationException {
        return false;
      }
    } else if (fd.type == 'gauge32') {
      final parsed = int.tryParse(strVal);
      if (parsed == null || parsed < 0 || parsed > Gauge32.maxValue) return false;
    } else if (fd.type == 'gauge64') {
      final parsed = BigInt.tryParse(strVal);
      if (parsed == null || parsed.isNegative || parsed > Gauge64.maxValue) return false;
    } else if (fd.type == 'hours32') {
      final parsed = int.tryParse(strVal);
      if (parsed == null) return false;
      try {
        Hours32(parsed);
      } on DurationValidationException {
        return false;
      }
    } else if (fd.type == 'minutes32') {
      final parsed = int.tryParse(strVal);
      if (parsed == null) return false;
      try {
        Minutes32(parsed);
      } on DurationValidationException {
        return false;
      }
    } else if (fd.type == 'seconds32') {
      final parsed = int.tryParse(strVal);
      if (parsed == null) return false;
      try {
        Seconds32(parsed);
      } on DurationValidationException {
        return false;
      }
    } else if (fd.type == 'milliseconds32') {
      final parsed = int.tryParse(strVal);
      if (parsed == null) return false;
      try {
        Milliseconds32(parsed);
      } on DurationValidationException {
        return false;
      }
    } else if (fd.type == 'dateAndTime') {
      try {
        YangDateTime.parse(strVal);
      } on DateTimeValidationException {
        return false;
      }
    } else if (fd.type == 'date') {
      try {
        YangDate.parse(strVal);
      } on DateTimeValidationException {
        return false;
      }
    } else if (fd.type == 'dateNoZone') {
      try {
        YangDateNoZone.parse(strVal);
      } on DateTimeValidationException {
        return false;
      }
    } else if (fd.type == 'time') {
      try {
        YangTime.parse(strVal);
      } on DateTimeValidationException {
        return false;
      }
    } else if (fd.type == 'timeNoZone') {
      try {
        YangTimeNoZone.parse(strVal);
      } on DateTimeValidationException {
        return false;
      }
    }
  }
  return true;
}
