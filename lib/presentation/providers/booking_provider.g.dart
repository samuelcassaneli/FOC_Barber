// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceRepositoryHash() => r'1f840ca36ff0bc0998f0e7278ecbc0ff8463140f';

/// See also [serviceRepository].
@ProviderFor(serviceRepository)
final serviceRepositoryProvider =
    AutoDisposeProvider<ServiceRepositoryImpl>.internal(
  serviceRepository,
  name: r'serviceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ServiceRepositoryRef = AutoDisposeProviderRef<ServiceRepositoryImpl>;
String _$barberRepositoryHash() => r'df06bb7d1a00e3332e25ac918b8d45ec81e835bf';

/// See also [barberRepository].
@ProviderFor(barberRepository)
final barberRepositoryProvider =
    AutoDisposeProvider<BarberRepositoryImpl>.internal(
  barberRepository,
  name: r'barberRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$barberRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BarberRepositoryRef = AutoDisposeProviderRef<BarberRepositoryImpl>;
String _$bookingRepositoryHash() => r'7a6da04dfbc2b7595f0af571b79a900b26821f9c';

/// See also [bookingRepository].
@ProviderFor(bookingRepository)
final bookingRepositoryProvider =
    AutoDisposeProvider<BookingRepositoryImpl>.internal(
  bookingRepository,
  name: r'bookingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BookingRepositoryRef = AutoDisposeProviderRef<BookingRepositoryImpl>;
String _$servicesHash() => r'190743dc37842ed463ab4b93b609436cbba0b358';

/// See also [services].
@ProviderFor(services)
final servicesProvider = AutoDisposeFutureProvider<List<ServiceModel>>.internal(
  services,
  name: r'servicesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$servicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ServicesRef = AutoDisposeFutureProviderRef<List<ServiceModel>>;
String _$barbersHash() => r'561818afad679f0b3508fe829224220267b2868f';

/// See also [barbers].
@ProviderFor(barbers)
final barbersProvider = AutoDisposeFutureProvider<List<BarberModel>>.internal(
  barbers,
  name: r'barbersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$barbersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BarbersRef = AutoDisposeFutureProviderRef<List<BarberModel>>;
String _$currentBarberHash() => r'08e9e5a80bb1644aad13544b2015612971c78b86';

/// See also [currentBarber].
@ProviderFor(currentBarber)
final currentBarberProvider = AutoDisposeFutureProvider<BarberModel?>.internal(
  currentBarber,
  name: r'currentBarberProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBarberHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentBarberRef = AutoDisposeFutureProviderRef<BarberModel?>;
String _$clientBookingsHash() => r'9943e969ab8eb3c77444f966e3e2cfd0ba3ae53f';

/// See also [clientBookings].
@ProviderFor(clientBookings)
final clientBookingsProvider =
    AutoDisposeFutureProvider<List<BookingModel>>.internal(
  clientBookings,
  name: r'clientBookingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientBookingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClientBookingsRef = AutoDisposeFutureProviderRef<List<BookingModel>>;
String _$nextClientBookingHash() => r'07b5b187b572d2ea57f30542b3d97c9c5ef1e124';

/// See also [nextClientBooking].
@ProviderFor(nextClientBooking)
final nextClientBookingProvider =
    AutoDisposeFutureProvider<BookingModel?>.internal(
  nextClientBooking,
  name: r'nextClientBookingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextClientBookingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NextClientBookingRef = AutoDisposeFutureProviderRef<BookingModel?>;
String _$userProfileHash() => r'77f4e73167b958d6f9b55b22461a157b9d7e022d';

/// See also [userProfile].
@ProviderFor(userProfile)
final userProfileProvider = AutoDisposeFutureProvider<ProfileModel?>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserProfileRef = AutoDisposeFutureProviderRef<ProfileModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
