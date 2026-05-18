import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile_entities.dart';
import 'map_picker_screen.dart';
import '../../../../core/constants/app_pallete.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final addresses = profileState.addresses;

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Delivery addresses',
          style: TextStyle(
            color: AppPallete.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: profileState.isLoading && addresses.isEmpty
          ? const Center(child: AppLoader())
          : Column(
              children: [
                if (profileState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profileState.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (profileState.successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profileState.successMessage!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: addresses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 220,
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/no_address.jpg',
                                    width: 220,
                                    height: 220,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "No delivery addresses yet",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppPallete.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add your delivery location so couriers can reach you quickly',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppPallete.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      : _buildAddressesList(addresses),
                ),

                // Bottom CTA
                Container(
                  color: AppPallete.backgroundColor,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: profileState.isLoading
                            ? null
                            : () async {
                                final result =
                                    await Navigator.push<Map<String, dynamic>>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MapPickerScreen(),
                                      ),
                                    );

                                if (result != null) {
                                  final addressText =
                                      result['address'] as String? ?? '';
                                  final lat = result['latitude'] as double?;
                                  final lng = result['longitude'] as double?;

                                  _showAddressDialog(
                                    address: null,
                                    initialAddress: addressText,
                                    initialLatitude: lat,
                                    initialLongitude: lng,
                                  );
                                }
                              },
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: AppPallete.textOnYellow,
                        ),
                        label: const Text(
                          'Add delivery address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppPallete.textOnYellow,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 6,
                          shadowColor: AppPallete.primaryYellowDark.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddressesList(List<AddressEntity> addresses) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        return _buildAddressCard(address);
      },
    );
  }

  Widget _buildAddressCard(AddressEntity address) {
    final isHome = address.label.toUpperCase() == AppLocalizations.of(context)!.home.toUpperCase();
    final isWork = address.label.toUpperCase() == AppLocalizations.of(context)!.work.toUpperCase();

    final icon = isHome
        ? Icons.home_outlined
        : isWork
        ? Icons.work_outline
        : Icons.location_on_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: address.isDefault
            ? Border.all(color: AppPallete.primaryYellowDark, width: 2)
            : Border.all(color: AppPallete.greyLight, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppPallete.primaryYellowLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppPallete.primaryDark, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppPallete.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppPallete.primaryYellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.defaultLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppPallete.textOnYellow,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  address.address,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPallete.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!address.isDefault)
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: AppPallete.primaryDarkLight,
                size: 22,
              ),
              onPressed: () => _setDefaultAddress(address.addressId),
              tooltip: AppLocalizations.of(context)!.setAsDefaultAddress,
            ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppPallete.primaryYellowDark,
              size: 22,
            ),
            onPressed: () => _showEditAddressSheet(address),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppPallete.error, size: 22),
            onPressed: () => _deleteAddress(address.addressId),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(int addressId) {
    ref.read(profileProvider.notifier).setDefaultAddress(addressId);
  }

  void _showEditAddressSheet(AddressEntity address) {
    _showAddressDialog(address: address);
  }

  void _showAddressDialog({
    AddressEntity? address,
    String? initialAddress,
    double? initialLatitude,
    double? initialLongitude,
  }) {
    final isEdit = address != null;
    final addressController = TextEditingController(
      text: address?.address ?? initialAddress ?? '',
    );
    final latController = TextEditingController(
      text: address?.latitude?.toString() ?? initialLatitude?.toString() ?? '',
    );
    final lngController = TextEditingController(
      text:
          address?.longitude?.toString() ?? initialLongitude?.toString() ?? '',
    );
    String selectedLabel = address?.label.toLowerCase() ?? AppLocalizations.of(context)!.home.toLowerCase();

    Future<void> openMapPicker() async {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => MapPickerScreen(
            initialLatitude: address?.latitude,
            initialLongitude: address?.longitude,
            initialAddress: address?.address,
          ),
        ),
      );

      if (result != null) {
        addressController.text = result['address'] ?? '';
        latController.text = result['latitude']?.toString() ?? '';
        lngController.text = result['longitude']?.toString() ?? '';
      }
    }

    // Helper to render a selectable type chip inside the bottom sheet
    Widget typeChipWidget(String labelText, StateSetter modalSetState) {
      final isSelected = selectedLabel == labelText.toLowerCase();
      return GestureDetector(
        onTap: () =>
            modalSetState(() => selectedLabel = labelText.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppPallete.primaryYellow : Colors.white,
            border: Border.all(
              color: isSelected
                  ? AppPallete.primaryYellow
                  : AppPallete.greyLight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              labelText,
              style: TextStyle(
                color: isSelected
                    ? AppPallete.textOnYellow
                    : AppPallete.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: StatefulBuilder(
                  builder: (context, modalSetState) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              isEdit
                                  ? AppLocalizations.of(context)!.editDeliveryAddress
                                  : AppLocalizations.of(context)!.deliveryAddress,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Address card with edit
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      addressController.text.isNotEmpty
                                          ? addressController.text
                                          : (initialAddress ?? ''),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: openMapPicker,
                                    child: Text(
                                      AppLocalizations.of(context)!.edit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.selectAddressType,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Type chips (Apartment / House / Office)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          32 -
                                          16) /
                                      3,
                                  child: typeChipWidget(
                                    AppLocalizations.of(context)!.apartment,
                                    modalSetState,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          32 -
                                          16) /
                                      3,
                                  child: typeChipWidget(AppLocalizations.of(context)!.house, modalSetState),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          32 -
                                          16) /
                                      3,
                                  child: typeChipWidget(
                                    AppLocalizations.of(context)!.work,
                                    modalSetState,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Address fields
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: addressController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.buildingNameStreet,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)!.apartmentNumber,
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)!.unitFloor,
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText:
                                        AppLocalizations.of(context)!.latitude,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Contact
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.contactPhoneNumber,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.contactPhoneNumberOptional,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // Save button
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final fullAddress = addressController.text
                                      .trim();
                                  if (fullAddress.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)!.pleaseEnterAnAddress,
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // Check for duplicate address (case-insensitive)
                                  final profileState = ref.read(
                                    profileProvider,
                                  );
                                  final addressLower = fullAddress
                                      .toLowerCase();

                                  bool
                                  isDuplicate = profileState.addresses.any((
                                    addr,
                                  ) {
                                    // If editing, skip checking the current address
                                    if (isEdit &&
                                        addr.addressId == address.addressId) {
                                      return false;
                                    }
                                    return addr.address.toLowerCase() ==
                                        addressLower;
                                  });

                                  if (isDuplicate) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!.thisAddressAlreadyExists,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  final lat = double.tryParse(
                                    latController.text,
                                  );
                                  final lng = double.tryParse(
                                    lngController.text,
                                  );

                                  if (isEdit) {
                                    await ref
                                        .read(profileProvider.notifier)
                                        .updateAddress(
                                          addressId: address.addressId,
                                          label: selectedLabel,
                                          address: fullAddress,
                                          latitude: lat,
                                          longitude: lng,
                                        );
                                  } else {
                                    await ref
                                        .read(profileProvider.notifier)
                                        .createAddress(
                                          label: selectedLabel,
                                          address: fullAddress,
                                          latitude: lat,
                                          longitude: lng,
                                          isDefault: false,
                                        );
                                  }

                                  if (mounted) Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPallete.primaryYellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: Text(
                                  isEdit
                                      ? AppLocalizations.of(
                                          context,
                                        )!.updateAddress
                                      : AppLocalizations.of(
                                          context,
                                        )!.saveAddress,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppPallete.textOnYellow,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteAddress(int addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAddress),
        content: Text(AppLocalizations.of(context)!.deleteAddressConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(profileProvider.notifier).deleteAddress(addressId);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
