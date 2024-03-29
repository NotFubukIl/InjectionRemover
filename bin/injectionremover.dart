import 'dart:io';

void main() {
  Process.run('cmd', ['/c', 'cls']);
  
  var DiscordContent = "module.exports = require('./core.asar');";
  var regex = [
    RegExp(r"app-1\.\d\.\d", caseSensitive: false),
    RegExp(r"discord_desktop_core-\d", caseSensitive: false)
  ];
  
  if (!Directory("./file").existsSync()) {
    Directory("./file").createSync();
  }
  String? local = Platform.environment["LOCALAPPDATA"]!;
  print("\x1b[34mCe programme redémarrera votre/vos Discord(s), voulez-vous continuer (y/n) ?:\x1b[0m ");
  var b = stdin.readLineSync();
  if (b == "y" || b == "Y") {
    main2(local, DiscordContent, regex);
  } else if (b == "n") {
    print("\x1b[34mFermeture du programme.\x1b[0m");
    exit(0);
  } else {
    print("\x1b[35mRépondez par y ou n.\x1b[0m");
    exit(1);
  }
}

void main2(String local, String DiscordContent, List<RegExp> regex) {
  Directory(local).listSync().forEach((entry) {
    if (entry.path.contains("iscord")) {
      var path = "${entry.path}";
      print("\x1b[32m${entry.path.split('/').last} trouvé ! Vérification en cours...\x1b[0m");
      check(path, DiscordContent, regex);
    }
  });
}

void check(String path, String DiscordContent, List<RegExp> regex) {
  String? local = Platform.environment["LOCALAPPDATA"]!;
  var Discord = path.split("\\")[5];
  Directory(path).listSync().forEach((entry) {
    if (entry.path.contains(regex[0])) {
      path = "${entry.path}/modules";
    } else {
      return;
    }
    Directory(path).listSync().forEach((entry) {
      if (entry.path.contains(regex[1])) {
        path = "${entry.path}/discord_desktop_core/index.js";
      } else {
        return;
      }
      var n = File(path).readAsStringSync();
      if (n != DiscordContent) {
        File(path).copySync("./file/${Discord}_index.js");
        print("\x1b[31mLe contenu de $Discord est suspect, veuillez regarder dans /file/${Discord}_index.js\x1b[0m\n\x1b[34mChangement de l'index..\x1b[0m");
        File(path).writeAsStringSync(DiscordContent);
        print("\x1b[32m$Discord rendu sûr !\nRedémarrage De $Discord en cours....\x1b[0m");
        redem(Discord, local);
      } else {
        print("\x1b[32mLe contenu de $Discord est normal :D\x1b[0m");
      }
    });
  });
}

void redem(String Discord, String local) {
  var killList = Process.runSync("tasklist", []).stdout.toString().split("\r\n");
  if (killList.contains("$Discord.exe")) {
    Process.runSync("taskkill", ["/IM", "$Discord.exe", "/F"]);
  } else {
    print("\x1b[32m$Discord n'est pas présent dans la liste des processus..\x1b[0m");
  }
  print("\x1b[33mDémarrage de $Discord\x1b[0m");
  Process.runSync("${local}/${Discord}/Update.exe", ["--processStart", "$Discord.exe"]);
}
