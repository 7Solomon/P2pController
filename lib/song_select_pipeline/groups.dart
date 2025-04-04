import 'package:P2pChords/dataManagment/data_class.dart';
import 'package:P2pChords/dataManagment/provider.dart';
import 'package:P2pChords/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'group.dart';
import 'package:P2pChords/styling/Tiles.dart';

class GroupOverviewpage extends StatefulWidget {
  const GroupOverviewpage({Key? key}) : super(key: key);

  @override
  _GroupOverviewpageState createState() => _GroupOverviewpageState();
}

class _GroupOverviewpageState extends State<GroupOverviewpage> {
  late DataLoadeProvider _dataProvider;
  late CurrentSelectionProvider _currentSelectionProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataLoadeProvider>(context, listen: false);
    _currentSelectionProvider =
        Provider.of<CurrentSelectionProvider>(context, listen: false);
  }

  Future<bool?> showShouldSendDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Senden der Gruppen Daten'),
          content: const Text('Willst du die Datein zu den clients Senden?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed No
              },
              child: const Text('Nein'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Yes
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alle Gruppen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _dataProvider.refreshData,
          ),
        ],
      ),
      body: _dataProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dataProvider.groups!.isEmpty
              ? const Center(child: Text('Keine Gruppen vorhanden'))
              : ListView.builder(
                  itemCount: _dataProvider.groups!.length,
                  itemBuilder: (context, index) {
                    String name = _dataProvider.groups!.keys.elementAt(index);
                    SongData songData = _dataProvider.getSongData(name);
                    return CListTile(
                      title: name,
                      context: context,
                      subtitle: 'Klicke um die Songs der Gruppe anzusehen',
                      icon: Icons.file_copy,
                      onTap: () async {
                        _currentSelectionProvider.setCurrentGroup(name);
                        if (connectionProvider.userState != UserState.client) {
                          if (connectionProvider.userState ==
                              UserState.server) {
                            bool? shouldSend = await showShouldSendDialog();

                            // If Yes, send data
                            if (shouldSend == true) {
                              bool success = await connectionProvider
                                  .dataSyncService
                                  .sendSongDataToAllClients(songData);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: success
                                      ? const Text(
                                          'Daten erfolgreich an alle Clients gesendet')
                                      : const Text(
                                          'Fehler beim Senden der Daten'),
                                ),
                              );
                            }
                          }

                          // Navigate to the SongOverviewPage
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Songoverviewpage(),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Du kannst keine Gruppen auswählen, wenn du ein Client bist'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
