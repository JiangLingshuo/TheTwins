"""Build tutorial XML from tutorial_master.ink; optionally import the four-column Excel text sheet."""
from pathlib import Path
import re,json,argparse,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'assets/dialogue'
parser=argparse.ArgumentParser()
parser.add_argument('--from-workbook')
args=parser.parse_args()
path=D/'tutorial_master.ink'
source=path.read_text(encoding='utf-8-sig')
if args.from_workbook:
 import openpyxl
 workbook=openpyxl.load_workbook(args.from_workbook,read_only=True,data_only=True)
 edits={str(r[3]):(r[1],str(r[2])) for r in workbook['教程文案_聊天同步'].iter_rows(min_row=6,values_only=True) if len(r)>=4 and r[3] and r[2] is not None}
 roles={'玩家':'player','Aurora':'aurora','旁白':'narrator','界面提示':'narrator','未知声音':'??'}
 lines=source.splitlines()
 for i,line in enumerate(lines):
  if line.startswith('// line_id:'):
   ident=line.split(':',1)[1]
   if ident in edits:
    role,text=edits[ident]
    old=re.search(r' #(player|aurora|narrator|\?\?)$',lines[i+1])
    lines[i+1]=' '.join(text.splitlines())+' #'+roles.get(role,old[1] if old else 'narrator')
 source='\n'.join(lines)+'\n'
 path.write_text(source,encoding='utf-8')
old_rows=json.loads((D/'tutorial_text_manifest.json').read_text(encoding='utf-8'))
old={r['id']:r for r in old_rows}
rows=[]
for block in re.finditer(r'^=== (\w+) ===\n(.*?)(?=^===|\Z)',source,re.M|re.S):
 knot,body=block.groups()
 xml=re.search(r'^# runtime_xml:([a-z0-9_]+\.xml)$',body,re.M)
 records=[]
 for line in re.finditer(r'^// line_id:([^\n]+)\n(.*?) #(player|aurora|narrator|\?\?)$',body,re.M):
  ident,text,role=line.groups()
  assert ident in old, 'Unknown stable line ID: '+ident
  record=dict(old[ident]);record.update(text=text,role={'player':'玩家','aurora':'Aurora','narrator':'旁白','??':'未知声音'}[role] if knot!='chat_guide_prompts' else '界面提示')
  rows.append(record);records.append((role,text))
 if xml:
  root=ET.Element('dialogue')
  for role,text in records:
   item=ET.SubElement(root,'line',speaker={'player':'#PLAYER#','aurora':'Aurora','??':'??','narrator':''}[role]);item.text=text.replace('{player_name}','#PLAYER#')
  ET.indent(root,space='  ')
  ET.ElementTree(root).write(D/xml[1],encoding='utf-8',xml_declaration=True)
# Editable guide prompt text is patched by its previous exact literal, preserving control logic.
script=ROOT/'scripts/sun_moon_tutorial.gd'
code=script.read_text(encoding='utf-8')
for record in rows:
 if record['knot']=='chat_guide_prompts' and old[record['id']]['text']!=record['text']:
  literal=json.dumps(old[record['id']]['text'],ensure_ascii=False)
  assert literal in code, 'Guide prompt changed outside text master: '+record['id']
  code=code.replace(literal,json.dumps(record['text'],ensure_ascii=False))
script.write_text(code,encoding='utf-8')
(D/'tutorial_text_manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Built',len(rows),'opening/tutorial/prompt records from tutorial_master.ink')
