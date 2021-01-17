module Compiler (compile, reduce, replace, replaceOrReduce) where

import Grammar
import Parser
import Mappings

import Data.Map (Map)
import qualified Data.Map as Map

compile :: Document -> String 
compile doc = concatMap toTex reduced
    where reduced = map (replaceOrReduce doc) (body doc)

replaceOrReduce :: Document -> Either SimpleTexObject TexObject -> TexObject
replaceOrReduce doc (Left x) = reduce doc x
replaceOrReduce doc (Right x) = replace doc x

reduce :: Document -> SimpleTexObject -> TexObject
reduce doc (StringInterpolation (Identifier i)) =
    if Map.notMember i (variables doc) then
        error $ "Undeclared Variable : " ++ i
    else
        Text $ variables doc Map.! i

reduce doc (StringInterpolation (Chem c)) =
    Text $ "\\ce{"++c++"}"

reduce doc (ComplexString xs) = Text $ concatMap (toTex . replaceOrReduce doc) xs

replace :: Document -> TexObject -> TexObject
replace doc (Text s)
            | Map.member s vars = Text $ vars Map.! s
            | s == ";" = Text ""
            | otherwise = Text s
            where vars = variables doc

replace doc (List xs) = List $ map (Right <$> replaceOrReduce doc) xs 

replace doc x = x
