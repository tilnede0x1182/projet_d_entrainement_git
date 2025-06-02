# Importations
import sys, os, json, glob, re

# Fonctions utilitaires
"""
Charge un JSON en liste de paires (ordre garanti)
@chemin chemin fichier
"""
def charger_fichier(chemin):
	with open(chemin,'r',encoding='utf-8') as f:
		return json.load(f,object_pairs_hook=list)

"""
Supprime \n, retire préfixe Mini cours :, sépare mini_cours / situation
@bloc texte brut
"""
def nettoyer(bloc):
	bloc=re.sub(r'\n','',bloc)
	bloc=re.sub(r'^Mini cours\s*:\s*','',bloc)
	mini,sit=bloc.split('Situation : ',1)
	return mini.strip(),sit.strip()

"""
Transforme une liste [ (cle,valeur) ] d'un exercice
@paires liste actuelle
"""
def maj_exercice(paires):
	numero_val=texte_val=questions_val=None
	for cle,val in paires:
		if cle=='numero': numero_val=val
		elif cle=='texte': texte_val=val
		elif cle=='questions': questions_val=val
	mini,sit=nettoyer(texte_val)
	return [('numero',numero_val),
	        ('mini_court',mini),
	        ('situation',sit),
	        ('questions',questions_val)]

# Fonctions principales
"""
Parcourt tous les json, applique transformation et réécrit
@dossier dossier cible
"""
def traiter_dossier(dossier='.'):
	for chemin in glob.glob(os.path.join(dossier,'*.json')):
		donnees=charger_fichier(chemin)
		for idx,(cle,val) in enumerate(donnees):
			if cle=='exercices':
				donnees[idx]=(cle,[maj_exercice(ex) for ex in val])
		with open(chemin,'w',encoding='utf-8') as f:
			f.write(dump_json(donnees))

# Dump JSON manuel (préserve ordre)
def dump_json(obj,indent=0):
	esp='  '*indent
	if isinstance(obj,list) and obj and isinstance(obj[0],tuple): # objet
		champs=[f'{esp}  "{k}": {dump_json(v,indent+1)}' for k,v in obj]
		return '{\n'+',\n'.join(champs)+'\n'+esp+'}'
	if isinstance(obj,list): # tableau
		elements=[dump_json(v,indent+1) for v in obj]
		return '[\n'+',\n'.join(f'{esp}  {e}' for e in elements)+'\n'+esp+']'
	return json.dumps(obj,ensure_ascii=False)

# Main
def main():
	dossier=sys.argv[1] if len(sys.argv)>1 else '.'
	traiter_dossier(dossier)

# Lancement du programme
if __name__=='__main__': main()
