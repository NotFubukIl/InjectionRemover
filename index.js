console.clear()

console.log = function (kill, yourself) {
    process.stdout.write(`${kill}\n`)
    if (yourself) setTimeout(() => process.exit(), 1000)
}
if (process.platform !== "win32") return console.log("\x1b[31mOnly Usable On Windows.\x1b[0m", true)

var fs = require("fs")
var {
    execSync
} = require("child_process")
var Readline = require("readline-sync")
var local = process.env.LOCALAPPDATA.replace(/\\/g, "/")
var DiscordContent = "module.exports = require('./core.asar');"
var regex = [new RegExp("app-1.[0-9].[0-9]", "i"), new RegExp("discord_desktop_core-[0-9]", "i")]


if (!fs.readdirSync(__dirname).includes("file")) fs.mkdirSync("./file")
var b = Readline.question("\x1b[34mCe Programme Redémarreras Votre/vos Discord(s), Voulez Vous Continuez (y/n) ?:\x1b[0m ").toLowerCase()
b == "y" ? main() : b == "n" ? console.log("\x1b[34mFermeture Du Programme.\x1b[0m", true) : console.log("\x1b[35mRépondez Par y ou n\x1b[0m", true)


function main() {
    fs.readdirSync(local).map(r => {
        if (r.includes("iscord")) {
            var path = `${local}/${r}`
            console.log(`\x1b[32m${r} Trouver ! About To Check...\x1b[0m`)
            check(path)
        }
    })
}

function check(path) {
    var Discord = path.split("/")[5]
    fs.readdirSync(path).map(r => {
        if (r.match(regex[0])) path += `/${r}/modules`
        else return
        fs.readdirSync(path).map(p => {
            if (p.match(regex[1])) path += `/${p}/discord_desktop_core/index.js`
            else return
            var n = fs.readFileSync(path).toString()
            if (n !== DiscordContent) {
                fs.copyFileSync(path, `./file/${Discord}_index.js`)
                console.log(`\x1b[31mLe Contenu De ${Discord} est suspect, veuillez regarder dans /file/${Discord}_index.js\x1b[0m\n\x1b[34mChangement De L'index..\x1b[0m`)
                fs.writeFile(path, DiscordContent, (err) => {
                    if (err) throw err
                    else console.log(`\x1b[32m${Discord} Rendu Safe !\nRedémarrage De ${Discord} En Cours....\x1b[0m`)
                    redem(Discord)
                })
            } else console.log(`\x1b[32mLe Contenu De ${Discord} est normal :D\x1b[0m`)
        })
    })
}

function redem(Discord) {
    var killList = execSync("tasklist").toString().split("\r\n")
    killList.includes(Discord) ? execSync(`taskkill /IM ${Discord}.exe /F`) : console.log(`\x1b[32m${Discord} n'est pas présent Dans Le Tasklist..\x1b[0m`)
    console.log(`\x1b[33mDémarrage De ${Discord}\x1b[0m`)
    execSync(`${local}/${Discord}/Update.exe --processStart ${Discord}.exe`)
}