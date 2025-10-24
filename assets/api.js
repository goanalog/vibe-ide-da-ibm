(function(){
  const env = (window.__VIBE_ENV__||{});
  const base = (env.FUNCTION_BASE_URL||"");
  const out = (id) => document.getElementById(id);

  async function ping(){
    try{
      if(!base){
        // Local mock when no function endpoint is configured
        const data = { status:"ok (local)", runtime:"mock", time:new Date().toISOString() };
        out("pingOut").textContent = JSON.stringify(data, null, 2);
        return;
      }
      const res = await fetch(base.replace(/\/$/,'') + "/ping");
      const data = await res.json();
      out("pingOut").textContent = JSON.stringify(data, null, 2);
    }catch(e){
      out("pingOut").textContent = "Ping failed: " + e.message;
    }
  }

  async function echo(){
    const text = document.getElementById("echoIn").value || "";
    try{
      if(!base){
        const data = { echo:text, source:"local-mock" };
        out("echoOut").textContent = JSON.stringify(data, null, 2);
        return;
      }
      const res = await fetch(base.replace(/\/$/,'') + "/echo", {method:"POST", headers:{ "content-type":"application/json"}, body: JSON.stringify({ text })});
      const data = await res.json();
      out("echoOut").textContent = JSON.stringify(data, null, 2);
    }catch(e){
      out("echoOut").textContent = "Echo failed: " + e.message;
    }
  }

  window.Vibe = { ping, echo };
})();