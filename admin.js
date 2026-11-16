(() => {
  const cfg = window.BLOOD_FREEDOM_SUPABASE || {};
  const $ = id => document.getElementById(id);
  const ready = cfg.url && cfg.anonKey && !cfg.url.includes("YOUR_") && !cfg.anonKey.includes("YOUR_") && window.supabase;
  const show = (id, yes) => $(id).classList.toggle("hidden", !yes);
  let client = null;
  const msg = (id, text, bad=false) => { $(id).textContent=text; $(id).style.color=bad?"#b42318":"#287443"; };
  if (!ready) {
    show("setup-warning",true);
    $("setup-warning").textContent="Setup required: add your Supabase Project URL and publishable/anon key in supabase-config.js, then run the admin SQL setup file in Supabase.";
    $("login-form").addEventListener("submit",e=>e.preventDefault());
    return;
  }
  client = window.supabase.createClient(cfg.url,cfg.anonKey);
  async function adminSession(session) {
    if (!session) { show("login-panel",true);show("dashboard",false);show("logout",false);return; }
    const {data:{user}} = await client.auth.getUser();
    if (!user || user.app_metadata?.role !== "admin") {
      await client.auth.signOut();msg("login-message","This account is not authorised as the master admin.",true);return;
    }
    show("login-panel",false);show("dashboard",true);show("logout",true);
    await Promise.all([loadCategories(),loadDesigns(),loadProducts()]);
  }
  $("login-form").addEventListener("submit",async e=>{
    e.preventDefault();msg("login-message","Signing in…");
    const {data,error}=await client.auth.signInWithPassword({email:$("email").value,password:$("password").value});
    if(error){msg("login-message",error.message,true);return;}
    await adminSession(data.session);
  });
  $("logout").addEventListener("click",async()=>{await client.auth.signOut();});
  client.auth.onAuthStateChange((_event,session)=>{setTimeout(()=>adminSession(session),0);});
  document.querySelector(".tabs").addEventListener("click",e=>{
    const b=e.target.closest("[data-tab]");if(!b)return;
    document.querySelectorAll(".tab").forEach(x=>x.classList.toggle("active",x===b));
    document.querySelectorAll(".tab-panel").forEach(x=>show(x.id,x.id==="tab-"+b.dataset.tab));
  });
  const safeSlug=s=>s.toLowerCase().trim().replace(/[^a-z0-9]+/g,"-").replace(/^-|-$/g,"");
  async function upload(bucket,file,path) {
    const {data,error}=await client.storage.from(bucket).upload(path,file,{upsert:false,contentType:file.type});
    if(error)throw error;return data.path;
  }
  async function loadCategories(){
    const {data,error}=await client.from("design_categories").select("id,name,slug,is_active,sort_order").order("sort_order").order("name");
    if(error){msg("category-message",error.message,true);return;}
    $("design-category").innerHTML=data.filter(x=>x.is_active).map(x=>'<option value="'+x.id+'">'+escapeHtml(x.name)+'</option>').join("");
    $("category-list").innerHTML=data.map(x=>'<div class="record"><div><strong>'+escapeHtml(x.name)+'</strong><small>'+escapeHtml(x.slug)+'</small></div><button data-category-toggle="'+x.id+'" data-active="'+x.is_active+'">'+(x.is_active?"Disable":"Enable")+'</button></div>').join("")||"<p>No categories yet.</p>";
  }
  async function loadDesigns(){
    const {data,error}=await client.from("pod_designs").select("id,name,is_active,created_at,design_categories(name)").order("created_at",{ascending:false});
    if(error){msg("design-message",error.message,true);return;}
    $("design-list").innerHTML=data.map(x=>'<div class="record"><div><strong>'+escapeHtml(x.name)+'</strong><small>'+escapeHtml(x.design_categories?.name||"Uncategorised")+' · '+(x.is_active?"Published":"Draft")+'</small></div><button data-design-toggle="'+x.id+'" data-active="'+x.is_active+'">'+(x.is_active?"Unpublish":"Publish")+'</button></div>').join("")||"<p>No designs uploaded yet.</p>";
  }
  async function loadProducts(){
    const {data,error}=await client.from("products").select("id,name,slug,category,audience_gender,is_active").order("created_at",{ascending:false});
    if(error){msg("product-message",error.message,true);return;}
    $("product-list").innerHTML=data.map(x=>'<div class="record"><div><strong>'+escapeHtml(x.name)+'</strong><small>'+escapeHtml(x.category)+' · '+escapeHtml(x.audience_gender||"audience not set")+' · '+(x.is_active?"Published":"Draft")+'</small></div><button data-product-toggle="'+x.id+'" data-active="'+x.is_active+'">'+(x.is_active?"Unpublish":"Publish")+'</button></div>').join("")||"<p>No products added yet.</p>";
  }
  $("design-form").addEventListener("submit",async e=>{
    e.preventDefault();const file=$("design-file").files[0];if(!file)return;
    if(file.size>15*1024*1024){msg("design-message","Image exceeds 15 MB.",true);return;}
    try{
      msg("design-message","Uploading…");
      const path=await upload("pod-design-source",file,Date.now()+"-"+safeSlug(file.name));
      const {error}=await client.from("pod_designs").insert({name:$("design-name").value.trim(),category_id:$("design-category").value,description:$("design-description").value.trim(),image_path:path,is_active:false});
      if(error)throw error;e.target.reset();await loadDesigns();msg("design-message","Design uploaded as draft. Publish it after review.");
    }catch(err){msg("design-message",err.message,true);}
  });
  $("product-form").addEventListener("submit",async e=>{
    e.preventDefault();try{
      msg("product-message","Saving…");let imagePath=null;const file=$("product-file").files[0];
      if(file){if(file.size>5*1024*1024)throw new Error("Product image exceeds 5 MB.");imagePath=await upload("product-images",file,Date.now()+"-"+safeSlug(file.name));}
      const row={name:$("product-name").value.trim(),slug:safeSlug($("product-slug").value),category:$("product-type").value,audience_gender:$("product-audience").value,description:$("product-description").value.trim(),is_active:$("product-active").checked};
      if(imagePath)row.image_path=imagePath;
      const {error}=await client.from("products").insert(row);if(error)throw error;
      e.target.reset();await loadProducts();msg("product-message","Product saved. Add its size/colour/price variants in the next catalogue step.");
    }catch(err){msg("product-message",err.message,true);}
  });
  $("category-form").addEventListener("submit",async e=>{
    e.preventDefault();const name=$("category-name").value.trim();const slug=safeSlug(name);
    try{const {error}=await client.from("design_categories").insert({name,slug,sort_order:99});if(error)throw error;e.target.reset();await loadCategories();msg("category-message","Category added.");}
    catch(err){msg("category-message",err.message,true);}
  });
  document.addEventListener("click",async e=>{
    const c=e.target.closest("[data-category-toggle]"),d=e.target.closest("[data-design-toggle]"),p=e.target.closest("[data-product-toggle]");
    try{
      if(c){const {error}=await client.from("design_categories").update({is_active:c.dataset.active!=="true"}).eq("id",c.dataset.categoryToggle);if(error)throw error;await loadCategories();}
      if(d){const {error}=await client.from("pod_designs").update({is_active:d.dataset.active!=="true"}).eq("id",d.dataset.designToggle);if(error)throw error;await loadDesigns();}
      if(p){const {error}=await client.from("products").update({is_active:p.dataset.active!=="true"}).eq("id",p.dataset.productToggle);if(error)throw error;await loadProducts();}
    }catch(err){alert(err.message);}
  });
  function escapeHtml(value){return String(value??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));}
  client.auth.getSession().then(({data})=>adminSession(data.session));
})();