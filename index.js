function Criar () {
    var1 = document.getElementById("var1").value;
    var2 = document.getElementById("var2").value;
    var3 = document.getElementById("var3").value;
    var4 = document.getElementById("var4").value;
    var5 = document.getElementById("var5").value;
    var6 = document.getElementById("var6").value;
    var7 = document.getElementById("var7").value;
    var8 = document.getElementById("var8").value;
    window.location = "https://localhost:7114/vpn/"+var1+"/"+var2+"/"+var3+"/"+var4+"/"+var5+"/"+var6+"/"+var7+"/"+var8;
};

function Revogar () {
    var1 = document.getElementById("var1").value;
    window.location = "https://localhost:7114/rvpn/"+var1;
}