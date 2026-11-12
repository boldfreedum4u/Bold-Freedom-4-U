const products=[
{id:1,name:"Freedom Graphic Tee",category:"tshirt",type:"Relaxed fit / Cotton",price:899,tone:"sand",garment:"",tag:"BESTSELLER"},
{id:2,name:"After Hours Hoodie",category:"hoodie",type:"Oversized / Fleece",price:1899,tone:"dark",garment:"cream",tag:"NEW DROP"},
{id:3,name:"Core Logo Tee",category:"tshirt",type:"Classic fit / Cotton",price:799,tone:"red",garment:"cream",tag:"EVERYDAY"},
{id:4,name:"Off-Duty Sweatshirt",category:"sweatshirt",type:"Relaxed fit / Fleece",price:1599,tone:"sand",garment:"redgarment",tag:""},
{id:5,name:"No Limits Hoodie",category:"hoodie",type:"Heavyweight / Fleece",price:1999,tone:"red",garment:"",tag:""},
{id:6,name:"Essential Sweatshirt",category:"sweatshirt",type:"Regular fit / Cotton blend",price:1499,tone:"dark",garment:"cream",tag:""}
];
let cart=[];
const money=n=>"₹"+n.toLocaleString("en-IN");
const grid=document.getElementById("product-grid");
function renderProducts(filter="all"){grid.innerHTML=products.filter(p=>filter==="all"||p.category===filter).map(p=>`<article class="product-card"><div class="product-visual ${p.tone}"><span class="product-tag">${p.tag||"BLOOD FREEDOM"}</span><div class="garment ${p.garment}"></div><button class="quick-add" data-add="${p.id}">ADD TO BAG +</button></div><div class="product-info"><div><h3>${p.name}</h3><p>${p.type}</p></div><span class="product-price">${money(p.price)}</span></div></article>`).join("");}
function renderCart(){const items=document.getElementById("cart-items");const count=cart.reduce((s,i)=>s+i.qty,0);document.getElementById("cart-count").textContent=count;document.getElementById("drawer-count").textContent="("+count+")";document.getElementById("cart-total").textContent=money(cart.reduce((s,i)=>s+i.price*i.qty,0));items.innerHTML=cart.length?cart.map(i=>`<div class="cart-line"><div class="cart-thumb">BF</div><div><h3>${i.name}</h3><p>${money(i.price)}</p><div class="qty"><button data-qty="${i.id}" data-change="-1" aria-label="Decrease quantity">−</button><span>${i.qty}</span><button data-qty="${i.id}" data-change="1" aria-label="Increase quantity">+</button></div></div><button class="remove" data-remove="${i.id}">REMOVE</button></div>`).join(""):'<p class="empty-cart">Your bag is waiting for something good.</p>';}
function openCart(){document.body.classList.add("cart-open");document.getElementById("cart-drawer").setAttribute("aria-hidden","false");}
function closeCart(){document.body.classList.remove("cart-open");document.getElementById("cart-drawer").setAttribute("aria-hidden","true");}
grid.addEventListener("click",e=>{const b=e.target.closest("[data-add]");if(!b)return;const p=products.find(x=>x.id===Number(b.dataset.add));const item=cart.find(x=>x.id===p.id);item?item.qty++:cart.push({...p,qty:1});renderCart();openCart();});
document.querySelector(".filters").addEventListener("click",e=>{const b=e.target.closest("[data-filter]");if(!b)return;document.querySelectorAll(".filter").forEach(x=>x.classList.toggle("active",x===b));renderProducts(b.dataset.filter);});
document.getElementById("cart-items").addEventListener("click",e=>{const q=e.target.closest("[data-qty]"),r=e.target.closest("[data-remove]");if(q){const i=cart.find(x=>x.id===Number(q.dataset.qty));i.qty+=Number(q.dataset.change);if(i.qty<=0)cart=cart.filter(x=>x.id!==i.id);}if(r)cart=cart.filter(x=>x.id!==Number(r.dataset.remove));renderCart();});
document.getElementById("cart-open").addEventListener("click",openCart);document.getElementById("cart-close").addEventListener("click",closeCart);document.getElementById("cart-backdrop").addEventListener("click",closeCart);
document.getElementById("checkout-button").addEventListener("click",()=>alert("Thanks for exploring Blood Freedom! Online checkout and payments will be added before launch."));
document.getElementById("newsletter-form").addEventListener("submit",e=>{e.preventDefault();document.getElementById("newsletter-message").textContent="Thanks! Newsletter signup will be connected before launch.";e.target.reset();});
document.getElementById("year").textContent=new Date().getFullYear();renderProducts();renderCart();