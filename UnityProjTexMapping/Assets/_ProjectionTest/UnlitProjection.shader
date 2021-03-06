﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/UnlitProjection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 tangent : TANGENT;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			
			float4x4 _tMat;
			float4x4 _projMat;
			float4x4 _viewMat;

			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);

				float4 worldPos = mul(unity_ObjectToWorld,float4(v.vertex.xyz, 1.0));
				float4 viewPos = mul(_viewMat, worldPos );
				float4 projPos = mul( _projMat, viewPos );

				o.tangent = mul(_tMat, projPos);//TRANSFORM_TEX(v.uv, _MainTex);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2DProj(texture, i.tangent);//tex2D(_MainTex, i.uv);
				
				//fixed4 col =tex2D(_MainTex, i.tangent.xy / i.tangent.w);
				fixed4 col = tex2D( _MainTex, i.tangent.xy / i.tangent.w );
				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
