import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../utility/constants.dart';
import '../screens/login/provider/login_provider.dart';

class TopHeader extends StatelessWidget {
  final String title;
  final Function(String) onSearch;

  const TopHeader({
    Key? key,
    required this.title,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(flex: 1),
        Expanded(
          child: SearchField(
            onChange: onSearch,
          ),
        ),
        const ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        final user = loginProvider.currentUser;
        return PopupMenuButton<int>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: secondaryColor,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 10),
                  Text("Logout"),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 1) {
              await loginProvider.logout();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: defaultPadding),
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding / 2,
            ),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/profile_pic.png",
                  height: 38,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                  child: Text(user?.email ?? "Admin"),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SearchField extends StatelessWidget {
  final Function(String) onChange;

  const SearchField({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
      onChanged: (value) {
        onChange(value);
      },
    );
  }
}
