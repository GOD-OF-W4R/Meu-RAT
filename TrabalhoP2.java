import java.io.*;
import java.text.DecimalFormat ;
public class TRABALHO_PRATICO2 
{
	public static void main (String[]args) throws IOException
	{
		BufferedReader br = new BufferedReader (new InputStreamReader(System.in));
		DecimalFormat mt = new DecimalFormat ("###,###,###.00 Mt");
   //declaracao de variaveis
		short cC=0 ,   cA=0 , cM=0  ;
		final int  NREFRI = 2000 , SEMREFRI= 500 ;
		float  acgo=0 ,ql=0 ,acp=0 , tx=0 ,acga=0 ,acA=0 , aC=0 , aM=0    ; 
		float acg=0 ,pn=0, qt=0 , pt=0 , vp=0 ;
		final float   PEN= 10/100f , TXGASOLINA = 5/100f , TXGASOLEO = 3/100f , TXCESPECIAL= 8/100f , TXSEMCE = 2/100f ;
		char tp=' ' , nR , cE , esT=' ', tpc=' ' , estC= ' ' , estA=' ' , estM=' ',r;
		float  pb=0 , pc=0 , qc =0  ;
		byte op ;
		System.out.println("/*******************************************************************************");
		System.out.println(" * +-------------------------------------------------------------------------+ *");
		System.out.println(" * |         INSTITUTO SUPERIOR DE CIÊNCIAS E TECNOLOGIAS DE MOÇAMBIQUE      | *");
		System.out.println(" * +-------------------------------------------------------------------------+ *");
		System.out.println(" * | CADEIRA: Introdução à Programação (IP)        | ANO: 1º Ano / 2026      | *");
		System.out.println(" * | TRABALHO: Trabalho Prático 2                  | TURMA:   B              | *");
		System.out.println(" * +-------------------------------------------------------------------------+ *");
		System.out.println(" * | ESTUDANTES:                                                             | *");
		System.out.println(" * |   1. Luis Carlos Belem                        - Código:20260881         | *");
		System.out.println(" * |   2. Dricio Correia                           - Código:20260473         | *");
		System.out.println(" * |   3. Jacinto Machava                          - Código:20260588         | *");
		System.out.println(" * +-------------------------------------------------------------------------+ *");
		System.out.println(" *******************************************************************************/");
		
		// Criamos a variável boolean que começa como falsa (pq não há dados ainda)
				boolean temDados = false;
				
				do 
				  {
					System.out.println(" ******** MENU ******** ");
					System.out.println("1 - Registar e Calcular Remessa");
					System.out.println("2 - Visualizar Tabela da Remessa");
					System.out.println("3 - Visualizar Quantidades, Totais e Penalizações");
					System.out.println("4 - Identificar Produto com Menor Custo");
					System.out.println("5 - Verificar Estado do Orçamento");
					System.out.println("6 - Terminar Programa");
					
					System.out.println("Introduza a opcao (1-6)");
					op = Byte.parseByte(br.readLine());
					
					switch (op) 
					
					  {
						  case 1 :
									do {
												// pn - penalizacao  , tx - taxa para controlo especial
												// inicializei porque o pn e tx estavam a acumular
										
												pn = 0;
												tx = 0;
												do 
												{
											      // tp = tipo de produto
													
													System.out.println("Informe o tipo de produto (C-combustivel , A-Alimento , M- Medicamentos)");
													tp = br.readLine().charAt(0);
													
													if(tp != 'C' && tp != 'c' && tp!= 'A' && tp!= 'a' && tp!= 'M' && tp!= 'm' )
													{
														System.out.println("Opcao invalida ! tente novamente ");
											         }
										
									              } while(tp != 'C' && tp != 'c' && tp!= 'A' && tp!= 'a' && tp!= 'M' && tp!= 'm' );
									
									          //pb= preco base por litro
								               // ql = quantidade de litros
									
									         switch (tp)
												{
												  case 'C':
												  case 'c':
													     do 
													       { 
													    	    System.out.println("introduza o preco base por litro (>0)");
													    	    pb = Float.parseFloat(br.readLine());
													    	 
													     	 if(pb <1)
													    	 	
														        {
														    		 System.out.println("Valor invalido ! Tente novamente");
														    		}
														    	 
														   }while(pb<1);
													     
													     do 
													     	{
													    	     System.out.println("introduza a quantidade de litros (ql>0) ");
													    	     ql = Float.parseFloat(br.readLine());
													    	 
														    	  if (ql<1)
														    	  	 {
														    		  System.out.println("Quantidade invalida  ! Tente novamente");
														    		  
														    	  	 }
														    	  
													     	}while(ql<1);
													     
													     vp = pb * ql ;
													  
														 do 
														 {
															 // tpc - tipo de combustivel
															 
															 System.out.println("Introduza o tipo de combustivel(G-Gasoleo , D-Gasolina)");
													     	tpc = br.readLine().charAt(0);
													     	
													       if (tpc!= 'd' && tpc!='D'&&tpc!= 'G' && tpc!= 'g')
													         {
													           System.out.println("Opcao invalida ! tente novamente ");
													         
													         }
												         } while( tpc!='d' && tpc!='D' &&tpc!='G' && tpc !='g');
														
														 //tx - taxa imposto sobre o gasoleo e gasolina
														
														 switch (tpc)
														 {
														 
															 case 'G':
															 case 'g':
																 tx = TXGASOLINA * vp ;
																 vp = vp + tx ;
																 acga= acga + vp;
																 break;
																 
															 case 'D':
															 case 'd':
																 tx = TXGASOLEO * vp ;
																 vp = vp + tx ;
																 acgo= acgo+vp ;
																 break ;
														 };
											 break ;
							
											case'A':
											case'a':
												    do
												     {
														System.out.println("introduza o preco por tonelada (>0)");
													    	pt = Float.parseFloat(br.readLine());
															    	
													    	 if (pt<1) 
													      {
													    		 System.out.println("opcao invalida! tente novamente ");
													    	  }
														    	 
													  }while(pt<1);
													    
													    do 
													    {
													     	System.out.println("introduza a quantidade de toneladas(>0)");
													     	qt = Float.parseFloat(br.readLine());	
													    	
													    	if(qt<1)
													    			{
													    		      System.out.println("Opcao invalida ! Tente novamente" );
													    		      
													    			}
												    	
												     }while(qt<1);
												    
												    vp = pt * qt ;
												    
												    do
												    {
													    	System.out.println("Ha necessidade de refrigeracao ?(S-sim , N-nao)");
													    	nR = br.readLine().charAt(0);
													    	
													    	if(nR != 'S' && nR != 's' && nR != 'N' && nR != 'n')
													     	{
													    		 System.out.println("opcao invalida ! tente novamente");
													     	}
												    	
												    }while(nR != 'S' && nR != 's' && nR != 'N' && nR != 'n');
												    
												    //Nrefri - necessidade de refrigeracao 
												    
												  if(nR=='s'||nR == 'S')
												  {
													vp = vp + NREFRI ;  
												  }
												  else
												  {
													  vp = vp + SEMREFRI ;
												  };
												 
												  break; 
											case 'M':
											case'm':
												do 
												{
													System.out.println("Introduza a quantidade de caixas (>0)");
													qc = Float.parseFloat(br.readLine());				if(qc<1) 
													{
														System.out.println("Quantidade invalida ! tente novamente");
														
													}
												}while(qc<1);
												
												do 
												{
													System.out.println("Introduza  o preco por caixas (qc>0)");
													pc= Float.parseFloat(br.readLine());
													
													if(pc<1) 
													{
														System.out.println("Preco por caixa invalido ! tente novamente");
													}
												}while(pc<1);
												
												vp = pc * qc ;
												
												do {
													//cE - controlo especial 
													// TXSEMCE - sem controlo especial
													
													System.out.println("ha Necessidade de controlo especial (S-sim ,N-nao) ");
													cE = br.readLine().charAt(0);
													if (cE!= 'S' && cE!= 's' && cE!= 'n'&& cE != 'N')
													{
														System.out.println("Opcao invalida ! tente novamente");
													}
												}while(cE!= 'S' && cE!= 's' && cE!= 'n'&& cE != 'N');
												
												 if (cE == 'S' || cE=='s')
												 	{
													  tx = TXCESPECIAL * vp ;
												 	}
												 else
												 	{
												 		tx = TXSEMCE * vp ;
												 	};
												 	
												 	vp = vp + tx ;
												 	
												
												break;
											    
											};
										
										//esT - estado de transporte 
											
										do
										{
											System.out.println("Informe o estado do transporte , se esta em atraso ! (A-Atrasado , N-no prazo)");
											esT = br.readLine().charAt(0);
											
											if(esT!='A' && esT != 'a' && esT!='n' && esT != 'N')
											{
												System.out.println("Opcao invalida! tente novamente");
												
											}	
										}
										while(esT!='A' && esT != 'a' && esT!='n' && esT != 'N');
										
										if (esT =='A' || esT=='a')
										{
											pn = PEN * vp ;
											acp = acp + pn ;
											
										}
										
										//acg - acomulador geral 
										
										vp= vp + pn ;
										acg = acg + vp ;
										
										// AQUI: Acumulei  ja com a multa inclusa
										//Guardamos o estado individual de cada produto para a tabela
										
													if (tp == 'C' || tp == 'c') 
													{
														cC++;
														aC = aC + vp;
														estC = esT ;
													} 
													else if (tp == 'A' || tp == 'a') 
													{
														cA++;
														acA = acA + vp;
														estA = esT ;
													} 
													else if (tp == 'M' || tp == 'm') 
													{
														cM++;
														aM = aM + vp;
														estM = esT ;
													}
										
										System.out.println("O valor a pagar :"+mt.format(vp));
										temDados = true;
										
										do {
											System.out.println("Deseja continuar ? (S-sim , N-nao)");
											r = br.readLine().charAt(0);
											
											if(r!='s' && r!='S' && r!='N' && r!= 'n')
											{
												System.out.println("Opcao invalida ! Tente novamente");
											}
									      }while(r!='s' && r!='S' && r!='N' &&r!= 'n');
											
									} while(r == 'S' ||r =='s');
						  break;
							        
				     // b) Verificação usando o boolean. Se for igual a false, avisa que não há dados.
							
			case 2:
			  if (temDados == false)
					
					{
						System.out.println("-------------------------------------------------------------");
						System.out.println("AVISO: Nao ha dados suficientes! inicie a Opção 1.");
						System.out.println("------------------------------------------------------------");
					}
					else
					  {
						System.out.println("=====================================================================================");
						System.out.println("| Remessa | Estado | Tipo |    Preço Unitário    |     Qt     | Valor a Pagar (MTn)   |");
						System.out.println("|-------------------------------------------------------------------------------------|");
						System.out.printf("|    C    |%8c|%6c|%22f|%12f|%23s|\n", estC, tpc, pb, ql, mt.format(aC));
						System.out.printf("|    A    |%8c|%6c|%22f|%12f|%23s|\n", estA, '-', pt, qt, mt.format(acA));
						System.out.printf("|    M    |%8c|%6c|%22f|%12f|%23s|\n", estM, '-', pc, qc, mt.format(aM));
						System.out.println("=====================================================================================");
					  }
						
		
			break;
				
			case 3:
				  if (temDados == false)
						
					{
						System.out.println("-------------------------------------------------------------");
						System.out.println("AVISO: Nao ha dados suficientes! inicie a Opção 1.");
						System.out.println("------------------------------------------------------------");
					}
					  else
					      {
							System.out.println("-----------------------------------------------------------------");
							System.out.println("|          Categoria     |  Nº Remessas  |   Total Acumulado    |");
							System.out.println("|---------------------------------------------------------------|");
							System.out.printf("|%24s|%15d|%22s|\n", "Combustíveis", cC, mt.format(aC));
							System.out.printf("|%24s|%15d|%22s|\n", "Produtos Alimentares", cA, mt.format(acA));
							System.out.printf("|%24s|%15d|%22s|\n", "Medicamentos", cM, mt.format(aM));
							System.out.println("|---------------------------------------------------------------|");
							System.out.printf("|%40s|%22s|\n", "Total Geral das Importações ", mt.format(acg));
							System.out.println("|---------------------------------------------------------------|");
							System.out.printf("|%40s|%22s|\n", "Total acumulado de Gasóleo ", mt.format(acgo));
							System.out.printf("|%40s|%22s|\n", "Total acumulado de Gasolina ", mt.format(acga));
							System.out.printf("|%40s|%22s|\n", "Total pago em penalizações ", mt.format(acp));
							System.out.println("-----------------------------------------------------------------");
					       }
			break;
				
			case 4:
				if (temDados == false)
				 {
					System.out.println("-------------------------------------------------------------");
					System.out.println("AVISO: Nao ha dados suficientes! inicie a Opção 1.");
					System.out.println("------------------------------------------------------------");
					
				 }
				  else
				  {
					if (acA < aC && acA < aM)
						{
							System.out.println("O  produto alimento possui menor custo");
						}else
							if(aC <aM && aC<acA)
						{
							System.out.println("O produto combustivel possui menor custo");
						}
						 else
						{
							System.out.println("O Produto medicamento possui menor custo");	
						}
					}
						   System.out.println("============================================================");
			break;
				
			case 5:
				if (temDados == false)
				{
					System.out.println("-------------------------------------------------------------");
					System.out.println("AVISO: Nao ha dados suficientes! inicie a Opção 1.");
					System.out.println("------------------------------------------------------------");
				}
					else
					{
						if (acg > 10000000)
						{
							System.out.println("Ultrapassou o Orçamento");
						}
						else 
						{
							System.out.println("Esta dentro do Orçamento");
						}
					}
								
						System.out.println ("============================================================");
	     break;
						
		case 6:
				System.out.println("Obrigado por utilizar os nossos servicos !");
				break;
				
		default:
				System.out.println("opcao invalida ! Tente novamente");
		   }

  } while(op != 6);
 }
}
