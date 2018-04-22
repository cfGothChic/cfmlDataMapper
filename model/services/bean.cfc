component accessors="true" output="false" {

  property BeanFactory;
  property DataFactory;
  property DataGateway;
  property SQLService;

	public component function init() {
		return this;
	}

  public void function populateById( required component bean, numeric id=0, string beanname="" ) {
		if ( !isNumeric(arguments.id) ) {
			arguments.id = 0;
		}
		arguments.bean.setBeanName( beanname=arguments.beanname );

		if ( arguments.id ) {
			var qRecord = variables.SQLService.read(
				beanname=arguments.bean.getBeanName(),
				methodname="populate",
				params={ id=arguments.id }
			);

			if ( qRecord.recordCount ) {
				populateByQuery( bean=arguments.bean, qRecord=qRecord );
			} else {
				arguments.id = 0;
			}
		}

		variables.id = arguments.id;
		// todo: arguments.bean.setPrimaryKey(arguments.id);
	}

  public void function populateByQuery( required component bean, required query qRecord ) {
		var columns = listToArray(qRecord.columnList);

		var properties = {};
		for ( var columnname in columns ) {
			properties[columnname] = qRecord[columnname][1];
		}

		variables.BeanFactory.injectProperties(arguments.bean, properties);
	}

  public void function populateBySproc(
    required component bean,
    required string sproc,
		string id="",
		string beanname="",
		array params=[],
		array resultkeys=[],
    string context
	) {
		if ( !isNumeric(arguments.id) ) {
			arguments.id = 0;
		}
    arguments.bean.setBeanName( beanname=arguments.beanname );

    // only pass arguments.context if it exists
		arguments.context = getSprocContext( argumentCollection=arguments );

		if ( arguments.id || arrayLen(arguments.params) ) {
  		var beanmap = arguments.bean.getBeanMap();

			if ( arguments.id ) {
				arrayAppend(arguments.params, { value=arguments.id, cfsqltype="cf_sql_integer" });
			}
			if ( len(arguments.context) && arguments.context != "default" ) {
				arrayAppend(arguments.params, { value=arguments.context, cfsqltype="cf_sql_varchar" });
			}

			if ( !arrayLen(arguments.resultkeys) ) {
				arguments.resultkeys = getRelationshipKeys( beanmap=beanmap, context=arguments.context );
			}

			var sprocData = variables.DataGateway.readSproc(
        sprocname=arguments.sproc,
        params=arguments.params,
        resultkeys=arguments.resultkeys
      );
			populateSprocData( bean=arguments.bean, beanmap=beanmap, data=sprocData, resultkeys=arguments.resultkeys );

			arguments.id = getPrimaryKeyFromSprocData( bean=arguments.bean, primarykey=beanmap.primarykey, data=sprocData );
		}

		arguments.bean.setPrimaryKey( primarykey=arguments.id );
	}

  public any function populateRelationship( required component bean, required string relationshipName ) {
    var value = arguments.bean.getPropertyValue( propertyname=arguments.relationshipName );

		if ( isSimpleValue(value) ) {
			var beanmap = arguments.bean.getBeanMap();

			if (
        !structKeyExists(beanmap,"relationships")
        || !structKeyExists(beanmap.relationships,arguments.relationshipName)
      ) {
				throw ("A " & arguments.relationshipName & " relationship is not defined in the " & beanmap.name & " bean map.");
			}

			var relationship = beanmap.relationships[ arguments.relationshipName ];
      var primarykeyid = arguments.bean.getPropertyValue( propertyname=beanmap.primarykey );

			switch ( relationship.joinType ) {
				case "one":
					value = getRelationshipBean( bean=arguments.bean, relationship=relationship );
					break;
				case "one-to-many":
					value = getOneToManyRelationship( primarykeyid=primarykeyid, relationship=relationship );
					break;
				case "many-to-many":
					value = getManyToManyRelationship( primarykeyid=primarykeyid, relationship=relationship );
					break;
			}

			if ( !isSimpleValue(value) ) {
				variables.BeanFactory.injectProperties(arguments.bean, { "#arguments.relationshipName#" = value });
			}
		}

    return value;
	}

  private array function getManyToManyRelationship( required numeric primarykeyid, required struct relationship ) {
		if ( arguments.primarykeyid ) {
			var qRecords = variables.SQLService.readByJoin(
				beanid = arguments.primarykeyid,
				relationship = arguments.relationship
			);
			return variables.DataFactory.getBeans( bean=arguments.relationship.bean, qRecords=qRecords );
		} else {
			return [];
		}
	}

  private array function getOneToManyRelationship( required numeric primarykeyid, required struct relationship ) {
		if ( arguments.primarykeyid ) {
			return variables.DataFactory.list(
				bean = arguments.relationship.bean,
				params = { "#arguments.relationship.fkName#" = arguments.primarykeyid }
			);
		} else {
			return [];
		}
	}

  private numeric function getPrimaryKeyFromSprocData(
    required component bean,
    required string primarykey,
    required struct data
  ) {
		if ( arguments.data._bean.recordCount ) {
			return arguments.bean.getPropertyValue( propertyname=arguments.primarykey );
		} else {
			return 0;
		}
	}

  private component function getRelationshipBean( required component bean, required struct relationship ) {
    var fkid = arguments.bean.getPropertyValue( propertyname=arguments.relationship.fkName );
		return variables.DataFactory.get( bean=arguments.relationship.bean, id=fkid );
	}

  private array function getRelationshipKeys( required struct beanmap, string context="" ) {
		var relationshipkeys = [];
		arrayAppend(relationshipkeys,"_bean");

		if ( len(arguments.context) && arguments.context != "_bean" && structCount(arguments.beanmap.relationships) ) {
			for ( var key in arguments.beanmap.relationships ) {
				var contexts = arguments.beanmap.relationships[key].contexts;
				if ( !arrayLen(contexts) || arrayFindNoCase(contexts,arguments.context) ) {
					arrayAppend(relationshipkeys,key);
				}
			}
			arraySort(relationshipkeys,"textnocase");
		}

		return relationshipkeys;
	}

  private string function getSprocContext( string context ) {
		if ( structKeyExists(arguments, "context") && !len(arguments.context) ) {
			return "_bean";
		}
		else if ( !structKeyExists(arguments, "context") ) {
			return "";
		}
		else {
			return arguments.context;
		}
	}

  private any function getSprocRelationship(
    required string beanname,
    required string joinType,
    required query qRecords
  ) {
		var isSingular = ( arguments.joinType == "one" );
		if ( isSingular ) {
      var bean = variables.DataFactory.get( bean=arguments.beanname );
      populateByQuery( bean=bean, qRecords=arguments.qRecords );
      return bean;
		} else {
			return variables.DataFactory.getBeans( bean=arguments.beanname, qRecords=arguments.qRecords );
		}
	}

  private void function populateSprocData(
    required component bean,
    required struct beanmap,
    required struct data,
    required array resultkeys
  ) {
		var properties = {};
		for ( var relationship in arguments.resultkeys ) {

			if ( relationship == "_bean" ) {
				if ( arguments.data._bean.recordCount ) {
					populateByQuery( bean=arguments.bean, qRecord=arguments.data._bean );
				}
			}

			else {
				properties[relationship] = getSprocRelationship(
					beanname=arguments.beanmap.relationships[relationship].bean,
					joinType=arguments.beanmap.relationships[relationship].joinType,
					qRecords=arguments.data[relationship]
				);
			}
		}

		if ( structCount(properties) ) {
			variables.BeanFactory.injectProperties(arguments.bean, properties);
		}
	}

}
