<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Success">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Action complete</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="DnsCacheEntries">
		<xsl:apply-templates select="CacheEntry"/>
	</xsl:template>

	<xsl:template match="CacheEntry">
		<xsl:text>----------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Record Name : </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Record Type : </xsl:text>
		<xsl:value-of select="Data/@type"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Data/@typeStr"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  Entry Name : </xsl:text>
		<xsl:value-of select="EntryName"/>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Time To Live : </xsl:text>
		<xsl:choose>
			<xsl:when test="Ttl/@type = 'invalid'">
				<xsl:text>permanent</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="printTime">
					<xsl:with-param name="time" select="Ttl"/>
					<xsl:with-param name="formatDelta" select="'false'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>        Data : </xsl:text>
		<xsl:value-of select="Data"/>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="Dns">

		<xsl:text>id=</xsl:text>
		<xsl:value-of select="@id" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>Response = </xsl:text>
		<xsl:choose>
			<xsl:when test="Response">
				<xsl:text>yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />

		<xsl:text>OpCode: </xsl:text>
		<xsl:value-of select="@opCode" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>Authority: </xsl:text>
		<xsl:choose>
			<xsl:when test="Authority">
				<xsl:text>yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />

		<xsl:text>Truncated: </xsl:text>
		<xsl:choose>
			<xsl:when test="Truncated">
				<xsl:text>yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />

		<xsl:text>Recursion Available: </xsl:text>
		<xsl:choose>
			<xsl:when test="RecursionAvailable">
				<xsl:text>yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:text>no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />

		<xsl:text>Respond Code: 0x</xsl:text>
		<xsl:value-of select="ResponseCode/@code" />
		<xsl:text> (</xsl:text>
		<xsl:value-of select="ResponseCode" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />

		<xsl:apply-templates select="QuestionData" />
		<xsl:apply-templates select="AnswerData" />
		<xsl:apply-templates select="NameServerData" />
		<xsl:apply-templates select="AdditionalRecordsData" />
	</xsl:template>

	<xsl:template match="QuestionData">
		<xsl:text>Question Data:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="Question">
				<xsl:apply-templates select="Question" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    Type: </xsl:text>
				<xsl:value-of select="Type" />
				<xsl:text> | Class: </xsl:text>
				<xsl:value-of select="Class" />
				<xsl:call-template name="PrintReturn" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="AnswerData">
		<xsl:text>Answer Data:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="Answer">
				<xsl:apply-templates select="Answer" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    None</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:template>
	
	<xsl:template match="NameServerData">
		<xsl:text>Name Server Data:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="NameServer">
				<xsl:apply-templates select="NameServer" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    None</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:template>

	<xsl:template match="AdditionalRecordsData">
		<xsl:text>Additional Records Data:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="AdditionalData">
				<xsl:apply-templates select="AdditionalData" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    None</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:template>

	<xsl:template match="Answer">
		<xsl:text>    </xsl:text>
		<xsl:apply-templates select="String" />
		<xsl:text>    </xsl:text>
		<xsl:choose>
			<xsl:when test="TypeStr">
				<xsl:value-of select="TypeStr" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Unknown type (Type:</xsl:text>
				<xsl:value-of select="Type"/>
				<xsl:text> Class:</xsl:text>
				<xsl:value-of select="Class"/>
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    TTL: </xsl:text>
		<xsl:value-of select="@ttl" />
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="DnsData" />
		<xsl:text>    --------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="NameServer">
		<xsl:text>    </xsl:text>
		<xsl:apply-templates select="String" />
		<xsl:text>    </xsl:text>
		<xsl:value-of select="TypeStr" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    TTL: </xsl:text>
		<xsl:value-of select="@ttl" />
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="DnsData" />
		<xsl:text>    --------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="AdditionalData">
		<xsl:text>    </xsl:text>
		<xsl:apply-templates select="String" />
		<xsl:text>    </xsl:text>
		<xsl:value-of select="TypeStr" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    TTL: </xsl:text>
		<xsl:value-of select="@ttl" />
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="DnsData" />
		<xsl:text>    --------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="Question">
		<xsl:text>    </xsl:text>
		<xsl:apply-templates select="String" />
		<xsl:apply-templates select="DnsData" />
		<xsl:if test="Type or Class">
			<xsl:text>    Type: </xsl:text>
			<xsl:value-of select="Type" />
			<xsl:text> | Class: </xsl:text>
			<xsl:value-of select="Class" />
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="DnsData">
		<xsl:choose>
			<xsl:when test="@type = 'hostAddress'">
				<xsl:text>    Host Address : </xsl:text>
				<xsl:value-of select="." />
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
			<xsl:when test="@type = 'authorityZone'">
				<xsl:text>    Primary Name Server : </xsl:text>
				<xsl:apply-templates select="PrimaryNameServer/String" />
				<xsl:text>    Responsible Mailbox : </xsl:text>
				<xsl:apply-templates select="ResponsibleMailbox/String" />		
			</xsl:when>
			<xsl:when test="@type = 'nameServer'">
				<xsl:text>    Name Server : </xsl:text>
				<xsl:apply-templates select="String" />
			</xsl:when>
			<xsl:when test="@type = 'ownerPrimaryName'">
				<xsl:text>    Name : </xsl:text>
				<xsl:apply-templates select="String" />
			</xsl:when>
			<xsl:when test="@type = 'domain'">
				<xsl:text>    Domain : </xsl:text>
				<xsl:apply-templates select="String" />
			</xsl:when>
			<xsl:when test="@type = 'mailExchange'">
				<xsl:text>    Mailbox : </xsl:text>
				<xsl:apply-templates select="ExchangeMailbox/String" />
			</xsl:when>
			<xsl:when test="@type = 'hostInfo'">
				<xsl:text>    CPU Type : </xsl:text>
				<xsl:apply-templates select="CPUType/String" />
				<xsl:text>    Host Type : </xsl:text>
				<xsl:apply-templates select="HostType/String" />
			</xsl:when>
			<xsl:when test="@type = 'serviceLocation'">
				<xsl:text>    Priority : </xsl:text>
				<xsl:value-of select="Priority" />
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>      Weight : </xsl:text>
				<xsl:value-of select="Weight" />
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>        Port : </xsl:text>
				<xsl:value-of select="Port" />
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>      Target : </xsl:text>
				<xsl:apply-templates select="Target/String" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    Raw Data : </xsl:text>
				<xsl:value-of select="RawData"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="String">
		<xsl:if test="string-length(.) and not(position() = 1)">
			<xsl:text>.</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="String">
				<xsl:apply-templates select="String" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="position() = last()">
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>

</xsl:transform>