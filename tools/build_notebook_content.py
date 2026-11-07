"""Regenerate the runtime text catalog; Ink remains the authoring source."""
from pathlib import Path
import json,re,hashlib

ROOT=Path(__file__).resolve().parents[1] if Path(__file__).parent.name=='tools' else Path('C:/godotproject/TheTwins')
D=ROOT/'assets/dialogue'
ALIASES={'baby':'baby_tomb','scholar':'scholar_tomb','sun':'sun_tomb','altar':'altar_tomb','mother':'mother_tomb','father':'father_tomb','girl':'girl_tomb'}
SKETCH={'baby':'day/baby_single.png','scholar':'day/草稿/scholar.png','sun':'day/草稿/the rich.png','altar':'tombstone/single/alter_now_single.png','mother':'tombstone/single/mother_single.png','father':'tombstone/single/father_single.png','girl':'day/草稿/girl.png'}
def plain(s):
    return re.sub(r'<link="[^"]+">(.*?)</link>',r'\1',s).replace('<date>', '').replace('</date>', '').replace('{player_name}','#PLAYER#')
def knots(text):
    return list(re.finditer(r'^=== (\w+) ===\n(.*?)(?=^===|\Z)',text,re.M|re.S))
def metadata(block):
    out={}
    for key,value in re.findall(r'^# ([^:\n]+):([^\n]*)',block,re.M):out.setdefault(key,[]).append(value.strip())
    return out
stones={}
for m in knots((D/'tombstone_master.ink').read_text(encoding='utf-8-sig')):
    if not m[1].startswith('tombstone_'):continue
    meta=metadata(m[2]);tid=meta['tombstone_id'][0]
    body='\n'.join(l for l in m[2].splitlines() if l.strip() and not l.startswith(('#','//','->')))
    stones[ALIASES[tid]]={'id':ALIASES[tid],'source_id':tid,'title':meta['title'][0],'location':meta['location'][0],'description':plain(body),'sketch':'res://assets/Art/'+SKETCH[tid]}
evidence={};owner='baby'
starts={'crystal_marker_rubbing':'scholar','sun_reference':'sun','altar_infant_rubbing':'altar','night_mother_child_rubbing':'mother','night_father_child_rubbing':'father','girl_figure_rubbing':'girl'}
environment={'sky_sun_rubbing','dayfolk_appearance','moon_reference','night_city_crystal','sun_reference','ram_spirit_emblem','giant_footprint','twin_beast_trace','repeated_beast_motifs','dry_underground_river','skyway_reference','diary_cover','notebook_cover','history_coffin_illustration','day_city_coin'}
for m in knots((D/'evidence_master.ink').read_text(encoding='utf-8-sig')):
    if not m[1].startswith('ev_'):continue
    meta=metadata(m[2]);eid=meta['id'][0];owner=starts.get(eid,owner)
    body='\n'.join(l for l in m[2].splitlines() if not l.startswith(('#','//','->'))).strip()
    cat=meta['category'][0];tomb='' if eid in environment else ALIASES[owner]
    if eid=='scholar_no_traces':tomb=ALIASES['scholar']
    owners={'girl_teddy_bear':['girl_tomb'], 'night_mother_flower':['mother_tomb'], 'mother_daughter_flower_meaning':['mother_tomb'], 'infant_memorial_correspondence':['baby_tomb','altar_tomb'], 'paired_skin_pictures':['scholar_tomb','mother_tomb'], 'four_person_family_finding':['sun_tomb','girl_tomb']}.get(eid, [tomb] if tomb else [])
    evidence[eid]={'gravestones':owners,'id':eid,'title':meta['title'][0],'body':plain(body),'interactive_body':body,'category':cat,'gravestone':tomb,'metadata':meta,'source_knot':m[1]}
radio={}
for m in knots((D/'telecomm_master.ink').read_text(encoding='utf-8-sig')):
    if not m[1].startswith(('test_answer_','query_night_','opening','test_bonus','test_confrontation','test_open_ending','test_scholar_mausoleum','test_disappearance_','test_baby_personhood')):continue
    pending=[];part=0
    for line in m[2].splitlines():
        speech=re.match(r'^\s*(.*?)\s+#(aurora|player|narrator|\?\?)\s*$',line)
        if speech:pending.append({'speaker':{'aurora':'Aurora','player':'#PLAYER#','narrator':'','??':'??'}[speech[2]],'content':plain(speech[1])})
        mark=re.search(r'~ read_answers \+= AnswerId\.(\w+)',line)
        if mark and pending:
            radio[mark[1]]={'id':mark[1],'source_knot':m[1],'lines':pending};pending=[];part+=1
    if pending:radio[m[1]+'_tail']={'id':m[1]+'_tail','source_knot':m[1],'preview_only': bool(re.search(r'^\s*(?:[+*]|\{)',m[2],re.M)), 'lines':pending}
catalog={'version':1,'sources':{n:hashlib.sha256((D/n).read_bytes()).hexdigest() for n in ['evidence_master.ink','tombstone_master.ink','telecomm_master.ink']},'gravestones':stones,'evidence':evidence,'radio_answers':radio}
(D/'notebook_content.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Catalog: {len(stones)} gravestones, {len(evidence)} evidence, {len(radio)} authored radio text segments.')
