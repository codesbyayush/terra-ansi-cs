import { $ } from "bun";

const inipath = "./inventory.ini";
const grpvarpath = "./group_vars/windows"
const deploypath = "./deploy.yml"

const regex_for_ini_grp = /\[windows\][\s\S]*?(?=\n\s*\n|$)/g;
const regex_for_vals = /^ansible_password:\s*(.*)$/m

const secrets = await $`cd ../terraform-01 && terraform output -json`.json();

let ini = await Bun.file(inipath).text();
let grp_vars = await Bun.file(grpvarpath).text();

const match = ini.match(regex_for_ini_grp);

let new_hosts = "[windows]\n"

for (const ip of secrets.ec2_public_ips.value) {
    new_hosts += `${ip}\n`
}
if (match) {
    ini = ini.replace(regex_for_ini_grp, new_hosts);
    await Bun.write(inipath, ini);
} else {
    await Bun.write(inipath, new_hosts + ini)
}

grp_vars = grp_vars.replace(regex_for_vals, `ansible_password: "${secrets.ansible_password.value}"`)
await Bun.write(grpvarpath, grp_vars)

let deployText = await Bun.file(deploypath).text();
const deployToJsObj = await Bun.YAML.parse(deployText);

const newvars = {
    "ConnectionStrings__DefaultConnection": `Host=${secrets.rds_endpoint.value.split(":")[0]};Port=${secrets.rds_port.value};Database=${secrets.rds_db_name.value};Username=${secrets.rds_username.value};Password=${secrets.rds_password.value}`
}
deployToJsObj.tasks[0]["ansible.windows.win_environment"]["variables"] = newvars

deployText = Bun.YAML.stringify(deployToJsObj, null, 2);
await Bun.write(deploypath, deployText);