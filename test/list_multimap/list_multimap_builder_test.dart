// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library built_collection.test.list_multimap.list_multimap_builder_test;

import 'package:built_collection/built_collection.dart';
import 'package:quiver/collection.dart';
import 'package:test/test.dart';

import '../performance.dart';

void main() {
  group('ListMultimapBuilder', () {
    test('throws on attempt to create ListMultimapBuilder<dynamic, dynamic>',
        () {
      expect(() => new ListMultimapBuilder(), throwsA(anything));
    });

    test('throws on attempt to create ListMultimapBuilder<String, dynamic>',
        () {
      expect(
          () => new ListMultimapBuilder<String, dynamic>(), throwsA(anything));
    });

    test('throws on attempt to create ListMultimapBuilder<dynamic, String>',
        () {
      expect(
          () => new ListMultimapBuilder<dynamic, String>(), throwsA(anything));
    });

    test('allows ListMultimapBuilder<Object, Object>', () {
      new ListMultimapBuilder<Object, Object>();
    });

    test('throws on null key add', () {
      expect(() => new ListMultimapBuilder<int, String>().add(null, '0'),
          throwsA(anything));
    });

    test('throws on null value add', () {
      expect(() => new ListMultimapBuilder<int, String>().add(0, null),
          throwsA(anything));
    });

    test('throws on null key addAll', () {
      final mutableMultimap = new ListMultimap<int, String>();
      mutableMultimap.add(null, '0');

      expect(
          () => new ListMultimapBuilder<int, String>().addAll(mutableMultimap),
          throwsA(anything));
    });

    test('throws on null value addAll', () {
      final mutableMultimap = new ListMultimap<int, String>();
      mutableMultimap.add(0, null);

      expect(
          () => new ListMultimapBuilder<int, String>().addAll(mutableMultimap),
          throwsA(anything));
    });

    test('throws on wrong type value addValues', () {
      expect(
          () => new ListMultimapBuilder<int, String>()
              .addValues(0, new List<String>.from([0])),
          throwsA(anything));
    });

    test('has replace method that replaces all data', () {
      expect(
          (new ListMultimapBuilder<int, String>()
                ..replace({
                  1: ['1'],
                  2: ['2']
                }))
              .build()
              .toMap(),
          {
            1: ['1'],
            2: ['2']
          });
    });

    test('has addIterable method like Map.fromIterable', () {
      expect(
          (new ListMultimapBuilder<int, int>()..addIterable([1, 2, 3]))
              .build()
              .toMap(),
          {
            1: [1],
            2: [2],
            3: [3]
          });
      expect(
          (new ListMultimapBuilder<int, int>()
                ..addIterable([1, 2, 3], key: (element) => element + 1))
              .build()
              .toMap(),
          {
            2: [1],
            3: [2],
            4: [3]
          });
      expect(
          (new ListMultimapBuilder<int, int>()
                ..addIterable([1, 2, 3], value: (element) => element + 1))
              .build()
              .toMap(),
          {
            1: [2],
            2: [3],
            3: [4]
          });
      expect(
          (new ListMultimapBuilder<int, int>()
                ..addIterable([1, 2, 3],
                    values: (element) => <int>[element, element + 1]))
              .build()
              .toMap(),
          {
            1: [1, 2],
            2: [2, 3],
            3: [3, 4]
          });
    });

    // Lazy copies.

    test('does not mutate BuiltListMultimap following reuse of underlying Map',
        () {
      final multimap = new BuiltListMultimap<int, String>({
        1: ['1'],
        2: ['2']
      });
      final multimapBuilder = multimap.toBuilder();
      multimapBuilder.add(3, '3');
      expect(
          multimap.toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));
    });

    test('converts to BuiltListMultimap without copying', () {
      final makeLongListMultimapBuilder = () {
        final result = new ListMultimapBuilder<int, int>();
        for (int i = 0; i != 100000; ++i) {
          result.add(0, i);
        }
        return result;
      };
      final longListMultimapBuilder = makeLongListMultimapBuilder();
      final buildLongListMultimapBuilder =
          () => longListMultimapBuilder.build();

      expectMuchFaster(
          buildLongListMultimapBuilder, makeLongListMultimapBuilder);
    });

    test('does not mutate BuiltListMultimap following mutates after build', () {
      final multimapBuilder = new ListMultimapBuilder<int, String>({
        1: ['1'],
        2: ['2']
      });

      final map1 = multimapBuilder.build();
      expect(
          map1.toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));

      multimapBuilder.add(3, '3');
      expect(
          map1.toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));

      multimapBuilder.build();
      expect(
          map1.toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));

      multimapBuilder.add(4, '4');
      expect(
          map1.toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));

      multimapBuilder.build();
      expect(
          map1.toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));
    });

    test('returns identical BuiltListMultimap on repeated build', () {
      final multimapBuilder = new ListMultimapBuilder<int, String>({
        1: ['1', '2', '3']
      });
      expect(multimapBuilder.build(), same(multimapBuilder.build()));
    });

    // Modification of existing data.

    test('adds to copied lists', () {
      final multimap = new BuiltListMultimap<int, String>({
        1: ['1']
      });
      final multimapBuilder = multimap.toBuilder();
      expect((multimapBuilder..add(1, '2')).build().toMap(), {
        1: ['1', '2']
      });
    });

    test('removes from copied lists', () {
      final multimap = new BuiltListMultimap<int, String>({
        1: ['1', '2', '3']
      });
      final multimapBuilder = multimap.toBuilder();
      expect(multimapBuilder.remove(1, '2'), true);
      expect(multimapBuilder.build().toMap(), {
        1: ['1', '3']
      });
    });

    test('removes from copied lists to empty', () {
      final multimap = new BuiltListMultimap<int, String>({
        1: ['1']
      });
      final multimapBuilder = multimap.toBuilder();
      expect(multimapBuilder.remove(1, '1'), true);
      expect(multimapBuilder.build().toMap(), {});
    });

    test('removes all from copied lists', () {
      final value = ['1', '2', '3'];
      final multimap = new BuiltListMultimap<int, String>({1: value});
      final multimapBuilder = multimap.toBuilder();
      expect(multimapBuilder.removeAll(1).build().toList(), value);
      expect(multimapBuilder.build().toMap(), {});
    });

    test('clears copied lists', () {
      final multimap = new BuiltListMultimap<int, String>({
        1: ['1', '2', '3']
      });
      final multimapBuilder = multimap.toBuilder();
      expect((multimapBuilder..clear()).build().toMap(), {});
    });

    // Map.

    test('has a method like ListMultimap.add', () {
      expect(
          (new ListMultimapBuilder<int, String>({
            1: ['1']
          })
                ..add(2, '2'))
              .build()
              .toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));
      expect(
          (new BuiltListMultimap<int, String>({
            1: ['1']
          }).toBuilder()
                ..add(2, '2'))
              .build()
              .toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));
    });

    test('has a method like ListMultimap.addValues', () {
      expect(
          (new ListMultimapBuilder<int, String>({
            1: ['1']
          })
                ..addValues(2, ['2', '3']))
              .build()
              .toMap(),
          ({
            1: ['1'],
            2: ['2', '3']
          }));
      expect(
          (new BuiltListMultimap<int, String>({
            1: ['1']
          }).toBuilder()
                ..addValues(2, ['2', '3']))
              .build()
              .toMap(),
          ({
            1: ['1'],
            2: ['2', '3']
          }));
    });

    test('has a method like ListMultimap.addAll', () {
      final mutableMultimap = new ListMultimap<int, String>();
      mutableMultimap.add(1, '1');
      mutableMultimap.add(2, '2');
      expect(
          (new ListMultimapBuilder<int, String>()..addAll(mutableMultimap))
              .build()
              .toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));
      expect(
          (new BuiltListMultimap<int, String>().toBuilder()
                ..addAll(mutableMultimap))
              .build()
              .toMap(),
          ({
            1: ['1'],
            2: ['2']
          }));
    });

    test('has a method like ListMultimap.remove', () {
      final builder = new ListMultimapBuilder<int, String>({
        1: ['1'],
        2: ['2', '3']
      });
      expect(builder.remove(2, '3'), true);
      expect(builder.remove(2, '3'), false);
      expect(builder.remove(2, '7'), false);
      expect(builder.build().toMap(), {
        1: ['1'],
        2: ['2']
      });
      expect(
          (new BuiltListMultimap<int, String>({
            1: ['1'],
            2: ['2', '3']
          }).toBuilder()
                ..remove(2, '3'))
              .build()
              .toMap(),
          {
            1: ['1'],
            2: ['2']
          });
    });

    test('has a method like ListMultimap.removeAll', () {
      final value = ['2', '3'];
      final builder = new ListMultimapBuilder<int, String>({
        1: ['1'],
        2: value
      });
      expect(builder.removeAll(2).build().toList(), value);
      expect(builder.removeAll(2).build().toList(), []);
      expect(builder.removeAll(3).build().toList(), []);
      expect(builder.build().toMap(), {
        1: ['1']
      });
      expect(
          (new BuiltListMultimap<int, String>({
            1: ['1'],
            2: value
          }).toBuilder()
                ..removeAll(2))
              .build()
              .toMap(),
          {
            1: ['1']
          });
    });

    test('has a method like ListMultimap.clear', () {
      expect(
          (new ListMultimapBuilder<int, String>({
            1: ['1'],
            2: ['2']
          })
                ..clear())
              .build()
              .toMap(),
          {});
      expect(
          (new BuiltListMultimap<int, String>({
            1: ['1'],
            2: ['2']
          }).toBuilder()
                ..clear())
              .build()
              .toMap(),
          {});
    });

    test('has a method like ListMultimap[]', () {
      expect(
          new BuiltListMultimap<int, String>({
            1: ['1'],
            2: ['2'],
            3: ['3']
          })[2]
              .build()
              .toList(),
          ['2']);
      expect(
          new BuiltListMultimap<int, String>({
            1: ['1'],
            2: ['2'],
            3: ['3']
          })[4]
              .build()
              .toList(),
          []);
    });
  });
}
