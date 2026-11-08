"""Export the dialogue subset used by the temporary Godot radio UI.

This exports explicit instructions, not flattened answers. Unknown syntax fails
the build rather than silently joining mutually exclusive narrative branches.
"""
from pathlib import Path
import json,re,hashlib

ROOT=Path(__file__).resolve().parents[1] if Path(__file__).parent.name=='tools' else Path('C:/godotproject/TheTwins')
D=ROOT/'assets/dialogue'
source=(D/'telecomm_master.ink').read_text(encoding='utf-8-sig')
blocks=dict(re.findall(r'^=== (\w+) ===\n(.*?)(?=^===|\Z)',source,re.M|re.S))
catalog=json.loads((D/'notebook_content.json').read_text(encoding='utf-8'))
def statement(raw):
    line=raw.strip()
    speech=re.match(r'^(.*?)\s*#(aurora|player|narrator|\?\?)\s*$',line)
    if speech:return {'op':'line','speaker':{'aurora':'Aurora','player':'#PLAYER#','narrator':'','??':'??'}[speech[2]],'text':speech[1].replace('{player_name}','#PLAYER#')}
    if line.startswith('~ '):return {'op':'set','code':line[2:]}
    if line.startswith('# '):return {'op':'tag','value':line[2:]}
    if line.startswith('-> '):return {'op':'goto','target':line[3:].strip()}
    if line.startswith(('//','DEV:')) or not line:return None
    if not line.startswith(('{','}','*','+','-')):return {'op':'line','speaker':'','text':line}
    raise ValueError('Unsupported radio instruction: '+line)
def parse(lines):
    lines=[l for l in lines if l.strip() and not l.strip().startswith('//')]
    def seq(i):
        out=[]
        while i<len(lines):
            line=lines[i].strip()
            if line=='}':return out,i+1,'close'
            if line=='- else:':return out,i+1,'else'
            if line.startswith(('* ','+ ')):
                choices=[]
                while i<len(lines) and lines[i].strip().startswith(('* ','+ ')):
                    head=lines[i].strip();m=re.fullmatch(r'[+*]\s*(?:\{(.*?)\}\s*)?\[(.*?)\](?:\s*->\s*(\w+))?',head)
                    assert m,head
                    i+=1;body=[]
                    while i<len(lines) and not lines[i].strip().startswith(('* ','+ ')):
                        body.append(lines[i]);i+=1
                    if m[3]:body.insert(0,'-> '+m[3])
                    choices.append({'label':m[2],'condition':m[1] or 'true','body':parse(body),'once':head.startswith('*')})
                out.append({'op':'choices','items':choices});continue
            if line.startswith('{'):
                m=re.fullmatch(r'\{(.*?):\s*(.*?)\}',line)
                if m:
                    node=statement(m[2]);out.append({'op':'if','condition':m[1],'then':[node] if node else [],'else':[]});i+=1;continue
                assert line.endswith(':'),line
                condition=line[1:-1];yes,i,stop=seq(i+1);no=[]
                if stop=='else':no,i,stop=seq(i)
                assert stop=='close',condition
                out.append({'op':'if','condition':condition,'then':yes,'else':no});continue
            node=statement(line)
            if node:out.append(node)
            i+=1
        return out,i,'end'
    out,index,stop=seq(0);assert stop=='end';return out

questions=[];needed=set()
for tomb in ['baby','scholar','sun','altar','mother','father','girl']:
    body=blocks['test_radio_'+tomb]
    options=re.split(r'(?=^\+ )',body,flags=re.M)[1:]
    for option in options:
        head=option.splitlines()[0]
        m=re.match(r'^\+\s*(?:\{(.*?)\}\s*)?\[(.*?)\](?:\s*->\s*(\w+))?',head)
        assert m,head
        if m[2] in ['Collect a word from this call','End this call']:continue
        target=m[3] or re.search(r'->\s*(\w+)',option)[1]
        condition=m[1] or 'true'
        questions.append({'id':tomb+':'+target,'tomb':tomb+'_tomb','label':m[2],'condition':condition,'target':target,'hidden': 'has_tag(' in condition or 'submitted_id' in condition or target=='test_answer_altar_24'})
        needed.add(target)
stop_prefixes=('END','test_radio_','test_hub','test_end_call','return_night_glyph','test_disappearance_return','test_desc_girl')
needed.update(['test_confrontation','ending_false','test_walk'])
programs={}
while needed:
    name=needed.pop()
    if name in programs:continue
    assert name in blocks,name
    programs[name]=parse(blocks[name].splitlines())
    for target in re.findall(r'->\s*(\w+)',blocks[name]):
        if not target.startswith(stop_prefixes) and target not in programs:needed.add(target)

# Merge only truly equivalent submission records. Explicit id checks prevent merging.
exact_ids=set(re.findall(r'submitted_id\s*==\s*"([^"]+)"',source))
groups={};eid_to_group={}
for eid,e in catalog['evidence'].items():
    if eid=='sky_sun_rubbing':continue # navigation only
    tags=sorted(e['metadata'].get('evidence_tag',[]))
    key='tags:'+','.join(tags) if tags and eid not in exact_ids else 'id:'+eid
    group=next((g for g in groups.values() if g['signature']==key),None)
    if group is None:
        group={'id':eid,'title':e['title'],'members':[],'signature':key};groups[eid]=group
    group['members'].append(eid);eid_to_group[eid]=group['id']
for g in groups.values():
    if len(g['members'])>1:
        tags=catalog['evidence'][g['members'][0]]['metadata'].get('evidence_tag',[])
        if 'twin_beast_motif' in tags:g['title']='Twin-beast symbol records'
        elif 'moon_stone_offering' in tags:g['title']='Moon-shaped offerings'
        elif 'sun_shape' in tags:g['title']='Sun shape records'
        elif 'endless_path_motif' in tags:g['title']='Unending path symbols'
        elif 'crystal_god_motif' in tags:g['title']='Crystal God symbols'
        else:g['title']+=' — combined records'
def relevant_atoms(text):
    return set(re.findall(r'has_tag\(EvidenceTag\.(\w+)\)',text)),set(re.findall(r'submitted_id\s*==\s*"([^"]+)"',text))
for q in questions:
    text=blocks[q['target']];tags,ids=relevant_atoms(text+'\n'+q['condition'])
    if q['target']=='test_disappearance_hypothesis':
        tags={'dawn_disappearances'};ids=set() # later stages are selected at runtime
    def accepted(g):return any(eid in ids or tags.intersection(catalog['evidence'][eid]['metadata'].get('evidence_tag',[])) for eid in g['members'])
    awarded=set(re.findall(r'event:grant_evidence:(\w+)',text))
    def score(g):
        return max(100*(eid in ids)+10*(q['tomb'] in catalog['evidence'][eid].get('gravestones',[]))+len(tags.intersection(catalog['evidence'][eid]['metadata'].get('evidence_tag',[]))) for eid in g['members'])
    related=sorted(groups,key=lambda gid:(-score(groups[gid]),gid))
    correct=next((gid for gid in related if accepted(groups[gid]) and any(eid not in awarded for eid in groups[gid]['members'])),None)
    distractors=[gid for gid in related if not accepted(groups[gid]) and gid!=correct]
    if correct is None:correct=related[0];distractors=[gid for gid in related if gid!=correct]
    q['candidates']=[correct]+distractors[:2]
    assert len(set(q['candidates']))==3

# Author-reviewed candidates override the generated same-grave initial draft.
override_path=D/'radio_candidate_overrides.json'
overrides=json.loads(override_path.read_text(encoding='utf-8')) if override_path.exists() else {}
for q in questions:
    if q['id'] in overrides:
        q['candidates']=[eid_to_group[eid] for eid in overrides[q['id']]]
        assert len(set(q['candidates']))==3,q['id']
assert set(overrides)=={q['id'] for q in questions}, 'Every question needs an authored triple'
# Ordinary distractors must not satisfy a supported-answer tag. The infant moon
# question deliberately retains a second valid record for its appended answer.
for q in questions:
    if q['hidden'] or q['id']=='baby:test_answer_baby_8' or q['target']=='test_disappearance_hypothesis':
        continue
    tags, ids=relevant_atoms(blocks[q['target']])
    # The human-shape question has a comparison and a manuscript follow-up.
    first_distractor = 2 if q['id']=='baby:test_answer_baby_17' else 1
    for gid in q['candidates'][first_distractor:]:
        for eid in groups[gid]['members']:
            assert eid not in ids and not tags.intersection(catalog['evidence'][eid]['metadata'].get('evidence_tag',[])), (q['id'],eid)


defaults={}
for name,value in re.findall(r'^VAR (\w+) = ([^\n]+)',source,re.M):
    if value in ['true','false']:defaults[name]=value=='true'
    elif value=='()':defaults[name]=[]
    elif value.startswith('"'):defaults[name]=json.loads(value)
    elif value.isdigit():defaults[name]=int(value)
programs=dict(sorted(programs.items()))
stage_candidates=json.loads((D/'radio_stage_candidates.json').read_text())
for ids in stage_candidates.values():
    assert len(ids)==3 and len({eid_to_group[eid] for eid in ids})==3
out={'stage_candidates':stage_candidates,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'questions':questions,'programs':programs,'groups':groups,'evidence_groups':eid_to_group,'defaults':defaults}
(D/'radio_content.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Radio export:',len(questions),'questions,',len(programs),'programs,',len(groups),'submission groups.')
