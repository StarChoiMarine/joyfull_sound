import type { Checkin } from './types';
function hash(value:string){let h=2166136261;for(const char of value){h^=char.charCodeAt(0);h=Math.imul(h,16777619);}return h>>>0;}
export function starPosition(date:string,publicId:string){const h=hash(`${date}:${publicId}`);return{x:8+(h%84),y:10+((h>>>8)%62),size:3+((h>>>16)%5),delay:(h%20)/10};}
export function upsertCheckin(items:Checkin[],memberId:string,date:string,now:string){const found=items.find(x=>x.memberId===memberId&&x.date===date);if(found)return items.map(x=>x===found?{...x,count:Math.min(x.count+1,3),lastAt:now}:x);return[...items,{memberId,date,count:1,lastAt:now,publicId:`star-${hash(memberId+date).toString(36)}`}];}
